import '../../entities/barber_availability_entity.dart';
import '../../repositories/barber_availability_repository.dart';
import '../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class UpdateMyAvailabilityUseCase {
  final BarberAvailabilityRepository repository;

  UpdateMyAvailabilityUseCase(this.repository);

  Future<Either<Failure, List<BarberAvailabilityEntity>>> call(
    List<Map<String, dynamic>> availability,
  ) async {
    return await repository.updateMyAvailability(availability);
  }
}

