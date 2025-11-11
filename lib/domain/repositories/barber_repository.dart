import '../entities/barber_entity.dart';
import '../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

abstract class BarberRepository {
  Future<Either<Failure, List<BarberEntity>>> getBarbers();

  Future<Either<Failure, List<BarberEntity>>> getBestBarbers({int limit = 10});

  Future<Either<Failure, BarberEntity>> getBarberById(String id);

  Future<Either<Failure, List<BarberEntity>>> searchBarbers(String query);

  Future<Either<Failure, List<BarberEntity>>> getBarbersByCategory(
    String category,
  );

  Future<Either<Failure, List<BarberEntity>>> getTrendingBarbers();
}


