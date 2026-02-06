import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/leaderboard_result_entity.dart';
import '../../repositories/competition_repository.dart';

class GetLeaderboardUseCase {
  final CompetitionRepository repository;

  GetLeaderboardUseCase(this.repository);

  Future<Either<Failure, LeaderboardResultEntity>> call(
    String periodId, {
    int limit = 20,
    int offset = 0,
  }) {
    return repository.getLeaderboard(periodId, limit: limit, offset: offset);
  }
}
