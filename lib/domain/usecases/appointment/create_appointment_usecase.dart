import '../../entities/appointment_entity.dart';
import '../../repositories/appointment_repository.dart';
import '../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class CreateAppointmentUseCase {
  final AppointmentRepository repository;

  CreateAppointmentUseCase(this.repository);

  Future<Either<Failure, AppointmentEntity>> call({
    required String barberId,
    String? serviceId,
    required DateTime date,
    required String time,
    required String paymentMethod,
    String? paymentProof,
    String? notes,
  }) async {
    return await repository.createAppointment(
      barberId: barberId,
      serviceId: serviceId,
      date: date,
      time: time,
      paymentMethod: paymentMethod,
      paymentProof: paymentProof,
      notes: notes,
    );
  }
}

