import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import '../../models/promotion_model.dart';
import 'package:dio/dio.dart';

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

abstract class PromotionRemoteDataSource {
  Future<List<PromotionModel>> getPromotions();
  Future<PromotionModel?> getPromotionById(String id);
}

class PromotionRemoteDataSourceImpl implements PromotionRemoteDataSource {
  final Dio dio;

  PromotionRemoteDataSourceImpl(this.dio);

  @override
  Future<List<PromotionModel>> getPromotions() async {
    try {
      final response = await dio.get('${AppConstants.baseUrl}/api/promotions');

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data
            .map((json) => PromotionModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(response.data['message'] ?? 'Error al obtener promociones');
      }
    } on DioException catch (e) {
      appLogger.e('GetPromotions error: ${e.message}', error: e);
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Error de conexión. Verifica tu internet.');
      }
      throw ServerException(e.response?.data['message'] ?? 'Error de red al obtener promociones');
    } catch (e) {
      appLogger.e('GetPromotions unexpected error: $e', error: e);
      throw ServerException('Error inesperado al obtener promociones');
    }
  }

  @override
  Future<PromotionModel?> getPromotionById(String id) async {
    try {
      final response = await dio.get('${AppConstants.baseUrl}/api/promotions/$id');

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return PromotionModel.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw ServerException(response.data['message'] ?? 'Error al obtener promoción');
      }
    } on DioException catch (e) {
      appLogger.e('GetPromotionById error: ${e.message}', error: e);
      if (e.response?.statusCode == 404) {
        return null;
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Error de conexión. Verifica tu internet.');
      }
      throw ServerException(e.response?.data['message'] ?? 'Error de red al obtener promoción');
    } catch (e) {
      appLogger.e('GetPromotionById unexpected error: $e', error: e);
      throw ServerException('Error inesperado al obtener promoción');
    }
  }
}

