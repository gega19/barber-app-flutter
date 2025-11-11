import '../entities/barber_availability_entity.dart';
import '../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

abstract class BarberAvailabilityRepository {
  Future<Either<Failure, List<BarberAvailabilityEntity>>> getMyAvailability();
  Future<Either<Failure, List<BarberAvailabilityEntity>>> updateMyAvailability(
    List<Map<String, dynamic>> availability,
  );
  Future<Either<Failure, List<String>>> getAvailableSlots(String barberId, String date);
}

