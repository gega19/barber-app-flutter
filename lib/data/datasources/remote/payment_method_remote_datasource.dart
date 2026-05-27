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
  Future<List<PaymentMethodModel>> getPaymentMethods({String? barberId});
  Future<PaymentMethodModel> getPaymentMethodWithConfig(String id);

  Future<List<PaymentMethodModel>> getBarberPaymentOptions(String barberId);
  Future<List<PaymentMethodModel>> getBarberPaymentTemplates(String barberId);
  Future<PaymentMethodModel> saveBarberPaymentOption({
    required String barberId,
    String? id,
    required String name,
    String? icon,
    Map<String, dynamic>? config,
    bool? isActive,
    String? templateId,
    int? sortOrder,
  });
  Future<void> setBarberPaymentOptionEnabled(String id, {required bool isActive});

  Future<void> deleteBarberPaymentOption(String id);
}

class PaymentMethodRemoteDataSourceImpl implements PaymentMethodRemoteDataSource {
  final Dio dio;

  PaymentMethodRemoteDataSourceImpl(this.dio);

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods({String? barberId}) async {
    try {
      final query = barberId != null && barberId.isNotEmpty ? {'barberId': barberId} : <String, dynamic>{};
      final response = await dio.get(
        '${AppConstants.baseUrl}/api/payment-methods',
        queryParameters: query.isEmpty ? null : query,
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

  @override
  Future<List<PaymentMethodModel>> getBarberPaymentOptions(String barberId) async {
    try {
      final response = await dio.get(
        '${AppConstants.baseUrl}/api/barber-payment-options/$barberId',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data
            .map((json) => PaymentMethodModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw ServerException(response.data['message'] ?? 'Error al obtener métodos del barbero');
    } on DioException catch (e) {
      appLogger.e('getBarberPaymentOptions error: ${e.message}', error: e);
      throw ServerException(e.response?.data['message'] ?? 'Error al obtener métodos del barbero');
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<List<PaymentMethodModel>> getBarberPaymentTemplates(String barberId) async {
    try {
      final response = await dio.get(
        '${AppConstants.baseUrl}/api/barber-payment-options/templates/$barberId',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data
            .map((json) => PaymentMethodModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw ServerException(response.data['message'] ?? 'Error al obtener plantillas');
    } on DioException catch (e) {
      appLogger.e('getBarberPaymentTemplates error: ${e.message}', error: e);
      throw ServerException(e.response?.data['message'] ?? 'Error al obtener plantillas');
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<PaymentMethodModel> saveBarberPaymentOption({
    required String barberId,
    String? id,
    required String name,
    String? icon,
    Map<String, dynamic>? config,
    bool? isActive,
    String? templateId,
    int? sortOrder,
  }) async {
    try {
      final payload = <String, dynamic>{
        'barberId': barberId,
        'name': name,
        if (icon != null) 'icon': icon,
        if (config != null) 'config': config,
        if (isActive != null) 'isActive': isActive,
        if (templateId != null) 'templateId': templateId,
        if (sortOrder != null) 'sortOrder': sortOrder,
      };

      final response = id == null
          ? await dio.post('${AppConstants.baseUrl}/api/barber-payment-options', data: payload)
          : await dio.put('${AppConstants.baseUrl}/api/barber-payment-options/$id', data: payload);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] as Map<String, dynamic>;
        return PaymentMethodModel.fromJson(data);
      }

      throw ServerException(response.data['message'] ?? 'Error al guardar método de pago');
    } on DioException catch (e) {
      appLogger.e('saveBarberPaymentOption error: ${e.message}', error: e);
      throw ServerException(e.response?.data['message'] ?? 'Error al guardar método de pago');
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<void> setBarberPaymentOptionEnabled(
    String id, {
    required bool isActive,
  }) async {
    try {
      final response = await dio.patch(
        '${AppConstants.baseUrl}/api/barber-payment-options/$id/enabled',
        data: {'isActive': isActive},
      );

      if (response.statusCode != 200) {
        throw ServerException(
          response.data['message'] ?? 'Error al actualizar estado del método',
        );
      }
    } on DioException catch (e) {
      appLogger.e('setBarberPaymentOptionEnabled error: ${e.message}', error: e);
      throw ServerException(
        e.response?.data['message'] ?? 'Error al actualizar estado del método',
      );
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteBarberPaymentOption(String id) async {
    try {
      final response = await dio.delete(
        '${AppConstants.baseUrl}/api/barber-payment-options/$id',
      );

      if (response.statusCode != 200) {
        throw ServerException(response.data['message'] ?? 'Error al eliminar método de pago');
      }
    } on DioException catch (e) {
      appLogger.e('deleteBarberPaymentOption error: ${e.message}', error: e);
      throw ServerException(e.response?.data['message'] ?? 'Error al eliminar método de pago');
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }
}

