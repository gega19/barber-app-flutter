import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/competition_repository.dart';

class GetMyCompetitionResultUseCase {
  final CompetitionRepository repository;

  GetMyCompetitionResultUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>?>> call(
    String periodId,
    String barberId,
  ) {
    return repository.getMyResult(periodId, barberId);
  }
}
