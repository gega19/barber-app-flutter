import '../../repositories/barber_availability_repository.dart';
import '../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class GetAvailableSlotsUseCase {
  final BarberAvailabilityRepository repository;

  GetAvailableSlotsUseCase(this.repository);

  Future<Either<Failure, List<String>>> call(String barberId, String date) async {
    return await repository.getAvailableSlots(barberId, date);
  }
}

