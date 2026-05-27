import '../../entities/workplace_entity.dart';
import '../../repositories/workplace_repository.dart';
import '../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

/// Caso de uso para buscar barberías
class SearchWorkplacesUseCase {
  final WorkplaceRepository repository;

  SearchWorkplacesUseCase(this.repository);

  Future<Either<Failure, List<WorkplaceEntity>>> call(
    String query, {
    String? country,
  }) async {
    return await repository.searchWorkplaces(query, country: country);
  }
}
