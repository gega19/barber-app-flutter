import '../entities/barber_entity.dart';
import '../entities/barber_list_result.dart';
import '../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

abstract class BarberRepository {
  Future<Either<Failure, List<BarberEntity>>> getBarbers({String? country});

  Future<Either<Failure, List<BarberEntity>>> getBestBarbers({
    int limit = 10,
    int offset = 0,
    String? country,
  });

  Future<Either<Failure, BarberListResult>> getBestBarbersWithTotal({
    int limit = 10,
    int offset = 0,
    String? country,
  });

  Future<Either<Failure, BarberEntity>> getBarberById(String id);

  Future<Either<Failure, List<BarberEntity>>> searchBarbers(
    String query, {
    String? country,
  });

  Future<Either<Failure, List<BarberEntity>>> getBarbersByWorkplaceId(
    String workplaceId,
  );

  Future<Either<Failure, List<BarberEntity>>> getBarbersByCategory(
    String category, {
    String? country,
  });

  Future<Either<Failure, List<BarberEntity>>> getTrendingBarbers({String? country});

  Future<Either<Failure, void>> toggleFavorite(String barberId);

  Future<Either<Failure, List<BarberEntity>>> getFavorites();

  Future<Either<Failure, BarberEntity>> getBarberBySlug(String slug);
}
