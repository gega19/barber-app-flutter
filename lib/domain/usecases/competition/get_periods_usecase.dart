import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/competition_period_entity.dart';
import '../../repositories/competition_repository.dart';

class GetPeriodsUseCase {
  final CompetitionRepository repository;

  GetPeriodsUseCase(this.repository);

  Future<Either<Failure, List<CompetitionPeriodEntity>>> call({
    String? status,
  }) {
    return repository.getPeriods(status: status);
  }
}
