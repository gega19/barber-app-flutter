import '../../models/barber_availability_model.dart';
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

abstract class BarberAvailabilityRemoteDataSource {
  Future<List<BarberAvailabilityModel>> getMyAvailability();
  Future<List<BarberAvailabilityModel>> updateMyAvailability(List<Map<String, dynamic>> availability);
  Future<List<String>> getAvailableSlots(String barberId, String date);
}

class BarberAvailabilityRemoteDataSourceImpl implements BarberAvailabilityRemoteDataSource {
  final Dio dio;

  BarberAvailabilityRemoteDataSourceImpl(this.dio);

  @override
  Future<List<BarberAvailabilityModel>> getMyAvailability() async {
    try {
      final response = await dio.get(
        '${AppConstants.baseUrl}/api/barber-availability/me',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data
            .map((json) => BarberAvailabilityModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          response.data['message'] ?? 'Error al obtener disponibilidad',
        );
      }
    } on DioException catch (e) {
      appLogger.e('GetMyAvailability error: ${e.message}', error: e);
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Error de conexión. Verifica tu internet');
      }
      throw ServerException('Error al obtener disponibilidad: ${e.message}');
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<List<BarberAvailabilityModel>> updateMyAvailability(
    List<Map<String, dynamic>> availability,
  ) async {
    try {
      final response = await dio.put(
        '${AppConstants.baseUrl}/api/barber-availability/me',
        data: { 'availability': availability },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data
            .map((json) => BarberAvailabilityModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          response.data['message'] ?? 'Error al actualizar disponibilidad',
        );
      }
    } on DioException catch (e) {
      appLogger.e('UpdateMyAvailability error: ${e.message}', error: e);
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Error de conexión. Verifica tu internet');
      }
      throw ServerException('Error al actualizar disponibilidad: ${e.message}');
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> getAvailableSlots(String barberId, String date) async {
    try {
      // Obtener hora actual local del dispositivo para enviar al servidor
      final now = DateTime.now();
      final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      
      final response = await dio.get(
        '${AppConstants.baseUrl}/api/barber-availability/$barberId/slots',
        queryParameters: { 
          'date': date,
          'currentTime': currentTime, // Enviar hora local del cliente
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        final slots = data['availableSlots'] as List;
        return slots.map((slot) => slot as String).toList();
      } else {
        throw ServerException(
          response.data['message'] ?? 'Error al obtener slots disponibles',
        );
      }
    } on DioException catch (e) {
      appLogger.e('GetAvailableSlots error: ${e.message}', error: e);
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Error de conexión. Verifica tu internet');
      }
      throw ServerException('Error al obtener slots disponibles: ${e.message}');
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }
}

