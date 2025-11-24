import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import '../../models/appointment_model.dart';
import 'package:dio/dio.dart';

abstract class AppointmentRemoteDataSource {
  Future<List<AppointmentModel>> getAppointments();
  Future<List<AppointmentModel>> getBarberQueue(String barberId, {DateTime? date});
  Future<AppointmentModel> createAppointment({
    required String barberId,
    String? serviceId,
    required DateTime date,
    required String time,
    required String paymentMethod,
    String? paymentProof,
    String? notes,
  });
  Future<void> cancelAppointment(String appointmentId);
  Future<void> markAsAttended(String appointmentId);
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
  Future<List<AppointmentModel>> getBarberQueue(String barberId, {DateTime? date}) async {
    try {
      String url = '${AppConstants.baseUrl}/api/appointments/barber/$barberId/queue';
      
      if (date != null) {
        final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        url += '?date=$dateStr';
      }

      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final appointments = data['appointments'] as List;
        return appointments
            .map((json) => AppointmentModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(response.data['message'] ?? 'Error al obtener cola del barbero');
      }
    } on DioException catch (e) {
      appLogger.e('GetBarberQueue error: ${e.message}', error: e);
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Error de conexión. Verifica tu internet.');
      }
      throw ServerException(e.response?.data['message'] ?? 'Error de red al obtener cola');
    } catch (e) {
      appLogger.e('GetBarberQueue unexpected error: $e', error: e);
      throw ServerException('Error inesperado al obtener cola');
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
      
      // Obtener hora actual local del dispositivo para enviar al servidor
      final now = DateTime.now();
      final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      final response = await dio.post(
        '${AppConstants.baseUrl}/api/appointments',
        data: {
          'barberId': barberId,
          if (serviceId != null) 'serviceId': serviceId,
          'date': dateStr,
          'time': time,
          'paymentMethod': paymentMethod,
          'currentTime': currentTime, // Enviar hora local del cliente
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

  @override
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      final response = await dio.put(
        '${AppConstants.baseUrl}/api/appointments/$appointmentId/cancel',
      );

      if (response.statusCode == 200) {
        return;
      } else {
        throw ServerException(response.data['message'] ?? 'Error al cancelar cita');
      }
    } on DioException catch (e) {
      appLogger.e('CancelAppointment error: ${e.message}', error: e);
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Error de conexión. Verifica tu internet.');
      }
      throw ServerException(e.response?.data['message'] ?? 'Error de red al cancelar cita');
    } catch (e) {
      appLogger.e('CancelAppointment unexpected error: $e', error: e);
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Error inesperado al cancelar cita');
    }
  }

  @override
  Future<void> markAsAttended(String appointmentId) async {
    try {
      final response = await dio.put(
        '${AppConstants.baseUrl}/api/appointments/$appointmentId/attend',
      );

      if (response.statusCode == 200) {
        return;
      } else {
        throw ServerException(response.data['message'] ?? 'Error al marcar cita como atendida');
      }
    } on DioException catch (e) {
      appLogger.e('MarkAsAttended error: ${e.message}', error: e);
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Error de conexión. Verifica tu internet.');
      }
      throw ServerException(e.response?.data['message'] ?? 'Error de red al marcar como atendida');
    } catch (e) {
      appLogger.e('MarkAsAttended unexpected error: $e', error: e);
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Error inesperado al marcar como atendida');
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
