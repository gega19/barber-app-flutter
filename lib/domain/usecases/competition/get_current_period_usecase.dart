import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/competition_period_entity.dart';
import '../../repositories/competition_repository.dart';

class GetCurrentPeriodUseCase {
  final CompetitionRepository repository;

  GetCurrentPeriodUseCase(this.repository);

  Future<Either<Failure, CompetitionPeriodEntity?>> call() {
    return repository.getCurrentPeriod();
  }
}
