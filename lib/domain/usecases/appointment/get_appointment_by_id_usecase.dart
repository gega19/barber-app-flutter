import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/appointment_entity.dart';
import '../../repositories/appointment_repository.dart';

class GetAppointmentByIdUseCase {
  final AppointmentRepository repository;

  GetAppointmentByIdUseCase(this.repository);

  Future<Either<Failure, AppointmentEntity>> call(String id) async {
    return await repository.getAppointmentById(id);
  }
}
