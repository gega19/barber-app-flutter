import '../../entities/workplace_entity.dart';
import '../../repositories/workplace_repository.dart';
import '../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class GetNearbyWorkplacesUseCase {
  final WorkplaceRepository repository;

  GetNearbyWorkplacesUseCase(this.repository);

  Future<Either<Failure, List<WorkplaceEntity>>> call({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  }) async {
    return await repository.getNearbyWorkplaces(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );
  }
}

