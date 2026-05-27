import '../../entities/workplace_list_result.dart';
import '../../repositories/workplace_repository.dart';
import '../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class GetBestWorkplacesWithTotalUseCase {
  final WorkplaceRepository repository;

  GetBestWorkplacesWithTotalUseCase(this.repository);

  Future<Either<Failure, WorkplaceListResult>> call({
    int limit = 10,
    int offset = 0,
    String? country,
  }) async {
    return await repository.getBestWorkplacesWithTotal(
      limit: limit,
      offset: offset,
      country: country,
    );
  }
}
