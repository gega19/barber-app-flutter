import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/competition_period_entity.dart';
import '../entities/leaderboard_result_entity.dart';

abstract class CompetitionRepository {
  Future<Either<Failure, CompetitionPeriodEntity?>> getCurrentPeriod();
  Future<Either<Failure, List<CompetitionPeriodEntity>>> getPeriods({
    String? status,
  });
  Future<Either<Failure, CompetitionPeriodEntity?>> getPeriodById(
    String periodId,
  );
  Future<Either<Failure, LeaderboardResultEntity>> getLeaderboard(
    String periodId, {
    int limit = 20,
    int offset = 0,
  });
  Future<Either<Failure, Map<String, dynamic>?>> getMyResult(
    String periodId,
    String barberId,
  );
  Future<Either<Failure, Map<String, dynamic>?>> getBarberTopPositions(
    String barberId,
  );
  Future<Either<Failure, List<String>>> getHelpRules();
}
