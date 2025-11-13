import '../entities/appointment_entity.dart';
import '../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

/// Interfaz del repositorio de citas
abstract class AppointmentRepository {
  /// Obtiene todas las citas del usuario
  Future<Either<Failure, List<AppointmentEntity>>> getAppointments();

  /// Obtiene la cola del barbero para una fecha específica
  Future<Either<Failure, List<AppointmentEntity>>> getBarberQueue(String barberId, {DateTime? date});

  /// Crea una nueva cita
  Future<Either<Failure, AppointmentEntity>> createAppointment({
    required String barberId,
    String? serviceId,
    required DateTime date,
    required String time,
    required String paymentMethod,
    String? paymentProof,
    String? notes,
  });

  /// Cancela una cita
  Future<Either<Failure, void>> cancelAppointment(String appointmentId);

  /// Marca una cita como atendida (completada)
  Future<Either<Failure, void>> markAsAttended(String appointmentId);

  /// Califica una cita completada
  Future<Either<Failure, void>> rateAppointment({
    required String appointmentId,
    required int rating,
    String? comment,
  });
}


