import '../../models/workplace_model.dart';
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

abstract class WorkplaceRemoteDataSource {
  Future<List<WorkplaceModel>> getWorkplaces({int? limit});
  Future<WorkplaceModel> getWorkplaceById(String id);
  Future<List<WorkplaceModel>> getNearbyWorkplaces({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  });
}

class WorkplaceRemoteDataSourceImpl implements WorkplaceRemoteDataSource {
  final Dio dio;

  WorkplaceRemoteDataSourceImpl(this.dio);

  @override
  Future<List<WorkplaceModel>> getWorkplaces({int? limit}) async {
    try {
      final queryParams = limit != null ? {'limit': limit} : null;
      final response = await dio.get(
        '${AppConstants.baseUrl}/api/workplaces/public',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => WorkplaceModel.fromJson(json)).toList();
      } else {
        throw ServerException(response.data['message'] ?? 'Error al obtener lugares de trabajo');
      }
    } on DioException catch (e) {
      appLogger.e('GetWorkplaces error: ${e.message}', error: e);
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Error de conexión. Verifica tu internet');
      }
      throw ServerException('Error al obtener lugares de trabajo: ${e.message}');
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<WorkplaceModel> getWorkplaceById(String id) async {
    try {
      final response = await dio.get('${AppConstants.baseUrl}/api/workplaces/public/$id');

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return WorkplaceModel.fromJson(data);
      } else {
        throw ServerException(response.data['message'] ?? 'Error al obtener lugar de trabajo');
      }
    } on DioException catch (e) {
      appLogger.e('GetWorkplaceById error: ${e.message}', error: e);
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Error de conexión. Verifica tu internet');
      }
      throw ServerException('Error al obtener lugar de trabajo: ${e.message}');
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<List<WorkplaceModel>> getNearbyWorkplaces({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  }) async {
    try {
      final response = await dio.get(
        '${AppConstants.baseUrl}/api/workplaces/public/nearby',
        queryParameters: {
          'lat': latitude,
          'lng': longitude,
          'radius': radiusKm,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => WorkplaceModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          response.data['message'] ?? 'Error al obtener barberías cercanas',
        );
      }
    } on DioException catch (e) {
      appLogger.e('GetNearbyWorkplaces error: ${e.message}', error: e);
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Error de conexión. Verifica tu internet');
      }
      throw ServerException(
        'Error al obtener barberías cercanas: ${e.message}',
      );
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }
}
