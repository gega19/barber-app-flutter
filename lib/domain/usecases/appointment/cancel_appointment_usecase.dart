import '../../repositories/appointment_repository.dart';
import '../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class CancelAppointmentUseCase {
  final AppointmentRepository repository;

  CancelAppointmentUseCase(this.repository);

  Future<Either<Failure, void>> call(String appointmentId) async {
    return await repository.cancelAppointment(appointmentId);
  }
}

