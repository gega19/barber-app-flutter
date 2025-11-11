import '../../entities/barber_availability_entity.dart';
import '../../repositories/barber_availability_repository.dart';
import '../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class GetMyAvailabilityUseCase {
  final BarberAvailabilityRepository repository;

  GetMyAvailabilityUseCase(this.repository);

  Future<Either<Failure, List<BarberAvailabilityEntity>>> call() async {
    return await repository.getMyAvailability();
  }
}

