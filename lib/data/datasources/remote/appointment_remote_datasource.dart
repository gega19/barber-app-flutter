import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import '../../models/appointment_model.dart';
import 'package:dio/dio.dart';

abstract class AppointmentRemoteDataSource {
  Future<List<AppointmentModel>> getAppointments();
  Future<AppointmentModel> createAppointment({
    required String barberId,
    String? serviceId,
    required DateTime date,
    required String time,
    required String paymentMethod,
    String? paymentProof,
    String? notes,
  });
}

class AppointmentRemoteDataSourceImpl implements AppointmentRemoteDataSource {
  final Dio dio;

  AppointmentRemoteDataSourceImpl(this.dio);

  @override
  Future<List<AppointmentModel>> getAppointments() async {
    try {
      final response = await dio.get('${AppConstants.baseUrl}/api/appointments');

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data
            .map((json) => AppointmentModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(response.data['message'] ?? 'Error al obtener citas');
      }
    } on DioException catch (e) {
      appLogger.e('GetAppointments error: ${e.message}', error: e);
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Error de conexión. Verifica tu internet.');
      }
      throw ServerException(e.response?.data['message'] ?? 'Error de red al obtener citas');
    } catch (e) {
      appLogger.e('GetAppointments unexpected error: $e', error: e);
      throw ServerException('Error inesperado al obtener citas');
    }
  }

  @override
  Future<AppointmentModel> createAppointment({
    required String barberId,
    String? serviceId,
    required DateTime date,
    required String time,
    required String paymentMethod,
    String? paymentProof,
    String? notes,
  }) async {
    try {
      // Formatear fecha como YYYY-MM-DD
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final response = await dio.post(
        '${AppConstants.baseUrl}/api/appointments',
        data: {
          'barberId': barberId,
          if (serviceId != null) 'serviceId': serviceId,
          'date': dateStr,
          'time': time,
          'paymentMethod': paymentMethod,
          if (paymentProof != null && paymentProof.isNotEmpty) 'paymentProof': paymentProof,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
      );

      if (response.statusCode == 201) {
        final data = response.data['data'] as Map<String, dynamic>;
        return AppointmentModel.fromJson(data);
      } else {
        throw ServerException(response.data['message'] ?? 'Error al crear cita');
      }
    } on DioException catch (e) {
      appLogger.e('CreateAppointment error: ${e.message}', error: e);
      if (e.response?.statusCode == 409) {
        // Conflicto: slot ya reservado
        throw ServerException(e.response?.data['message'] ?? 'Este horario ya está reservado');
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Error de conexión. Verifica tu internet.');
      }
      throw ServerException(e.response?.data['message'] ?? 'Error de red al crear cita');
    } catch (e) {
      appLogger.e('CreateAppointment unexpected error: $e', error: e);
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Error inesperado al crear cita');
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
