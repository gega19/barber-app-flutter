import '../../models/payment_method_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import 'package:dio/dio.dart';

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => message;
}

abstract class PaymentMethodRemoteDataSource {
  Future<List<PaymentMethodModel>> getPaymentMethods();
  Future<PaymentMethodModel> getPaymentMethodWithConfig(String id);
}

class PaymentMethodRemoteDataSourceImpl implements PaymentMethodRemoteDataSource {
  final Dio dio;

  PaymentMethodRemoteDataSourceImpl(this.dio);

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    try {
      final response = await dio.get(
        '${AppConstants.baseUrl}/api/payment-methods',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data
            .map((json) => PaymentMethodModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          response.data['message'] ?? 'Error al obtener métodos de pago',
        );
      }
    } on DioException catch (e) {
      appLogger.e('GetPaymentMethods error: ${e.message}', error: e);
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Error de conexión. Verifica tu internet');
      }
      throw ServerException('Error al obtener métodos de pago: ${e.message}');
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<PaymentMethodModel> getPaymentMethodWithConfig(String id) async {
    try {
      final response = await dio.get(
        '${AppConstants.baseUrl}/api/payment-methods/$id/config',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return PaymentMethodModel.fromJson(data);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Error al obtener método de pago',
        );
      }
    } on DioException catch (e) {
      appLogger.e('GetPaymentMethodWithConfig error: ${e.message}', error: e);
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Error de conexión. Verifica tu internet');
      }
      throw ServerException('Error al obtener método de pago: ${e.message}');
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }
}

