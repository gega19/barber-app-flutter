import '../entities/workplace_entity.dart';
import '../entities/workplace_list_result.dart';
import '../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

abstract class WorkplaceRepository {
  Future<Either<Failure, List<WorkplaceEntity>>> getWorkplaces({
    int? limit,
    String? country,
  });
  Future<Either<Failure, WorkplaceListResult>> getBestWorkplacesWithTotal({
    int limit = 10,
    int offset = 0,
    String? country,
  });
  Future<Either<Failure, List<WorkplaceEntity>>> searchWorkplaces(
    String query, {
    String? country,
  });
  Future<Either<Failure, WorkplaceEntity>> getWorkplaceById(String id);
  Future<Either<Failure, List<WorkplaceEntity>>> getNearbyWorkplaces({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
    String? country,
  });
}
