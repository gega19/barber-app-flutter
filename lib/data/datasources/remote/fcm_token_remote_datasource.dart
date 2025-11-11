import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';

abstract class FcmTokenRemoteDataSource {
  Future<void> registerToken({
    required String token,
    required String deviceType,
  });

  Future<void> deleteToken(String token);

  Future<void> deleteUserTokens();
}

class FcmTokenRemoteDataSourceImpl implements FcmTokenRemoteDataSource {
  final Dio dio;

  FcmTokenRemoteDataSourceImpl(this.dio);

  @override
  Future<void> registerToken({
    required String token,
    required String deviceType,
  }) async {
    try {
      appLogger.i('📤 Enviando token FCM al backend: ${token.substring(0, 20)}...');
      final response = await dio.post(
        '${AppConstants.baseUrl}/api/fcm-tokens',
        data: {
          'token': token,
          'deviceType': deviceType,
        },
      );

      appLogger.i('📥 Respuesta del backend: ${response.statusCode} - ${response.data}');

      if (response.statusCode != 200) {
        throw ServerException(
          response.data['message'] ?? 'Error al registrar token FCM',
        );
      }
      
      appLogger.i('✅ Token FCM registrado exitosamente en el backend');
    } on DioException catch (e) {
      appLogger.e('❌ RegisterFcmToken error: ${e.message}', error: e);
      appLogger.e('❌ Response data: ${e.response?.data}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Error de conexión. Verifica tu internet.');
      }
      throw ServerException(
        e.response?.data['message'] ?? 'Error de red al registrar token FCM',
      );
    } catch (e) {
      appLogger.e('❌ RegisterFcmToken unexpected error: $e', error: e);
      throw ServerException('Error inesperado al registrar token FCM');
    }
  }

  @override
  Future<void> deleteToken(String token) async {
    try {
      final response = await dio.delete(
        '${AppConstants.baseUrl}/api/fcm-tokens/$token',
      );

      if (response.statusCode != 200) {
        throw ServerException(
          response.data['message'] ?? 'Error al eliminar token FCM',
        );
      }
    } on DioException catch (e) {
      appLogger.e('DeleteFcmToken error: ${e.message}', error: e);
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Error de conexión. Verifica tu internet.');
      }
      throw ServerException(
        e.response?.data['message'] ?? 'Error de red al eliminar token FCM',
      );
    } catch (e) {
      appLogger.e('DeleteFcmToken unexpected error: $e', error: e);
      throw ServerException('Error inesperado al eliminar token FCM');
    }
  }

  @override
  Future<void> deleteUserTokens() async {
    try {
      final response = await dio.delete(
        '${AppConstants.baseUrl}/api/fcm-tokens',
      );

      if (response.statusCode != 200) {
        throw ServerException(
          response.data['message'] ?? 'Error al eliminar tokens FCM',
        );
      }
    } on DioException catch (e) {
      appLogger.e('DeleteUserFcmTokens error: ${e.message}', error: e);
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Error de conexión. Verifica tu internet.');
      }
      throw ServerException(
        e.response?.data['message'] ?? 'Error de red al eliminar tokens FCM',
      );
    } catch (e) {
      appLogger.e('DeleteUserFcmTokens unexpected error: $e', error: e);
      throw ServerException('Error inesperado al eliminar tokens FCM');
    }
  }
}

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

