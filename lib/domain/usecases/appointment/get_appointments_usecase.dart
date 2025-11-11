import '../../entities/appointment_entity.dart';
import '../../repositories/appointment_repository.dart';
import '../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class GetAppointmentsUseCase {
  final AppointmentRepository repository;

  GetAppointmentsUseCase(this.repository);

  Future<Either<Failure, List<AppointmentEntity>>> call() async {
    return await repository.getAppointments();
  }
}
