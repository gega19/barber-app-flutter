import '../../repositories/appointment_repository.dart';
import '../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class MarkAsAttendedUseCase {
  final AppointmentRepository repository;

  MarkAsAttendedUseCase(this.repository);

  Future<Either<Failure, void>> call(String appointmentId) async {
    return await repository.markAsAttended(appointmentId);
  }
}

