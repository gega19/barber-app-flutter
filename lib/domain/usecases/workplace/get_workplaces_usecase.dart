import '../../entities/workplace_entity.dart';
import '../../repositories/workplace_repository.dart';
import '../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class GetWorkplacesUseCase {
  final WorkplaceRepository repository;

  GetWorkplacesUseCase(this.repository);

  Future<Either<Failure, List<WorkplaceEntity>>> call({int? limit}) async {
    return await repository.getWorkplaces(limit: limit);
  }
}
