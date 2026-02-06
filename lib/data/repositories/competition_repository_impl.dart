import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/competition_period_entity.dart';
import '../../domain/entities/leaderboard_result_entity.dart';
import '../../domain/repositories/competition_repository.dart';
import '../datasources/remote/competition_remote_datasource.dart';

class CompetitionRepositoryImpl implements CompetitionRepository {
  final CompetitionRemoteDataSource remoteDataSource;

  CompetitionRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, CompetitionPeriodEntity?>> getCurrentPeriod() async {
    try {
      final period = await remoteDataSource.getCurrentPeriod();
      return Right(period);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CompetitionPeriodEntity>>> getPeriods({
    String? status,
  }) async {
    try {
      final list = await remoteDataSource.getPeriods(status: status);
      return Right(list);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CompetitionPeriodEntity?>> getPeriodById(
    String periodId,
  ) async {
    try {
      final period = await remoteDataSource.getPeriodById(periodId);
      return Right(period);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LeaderboardResultEntity>> getLeaderboard(
    String periodId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final result = await remoteDataSource.getLeaderboard(
        periodId,
        limit: limit,
        offset: offset,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>?>> getMyResult(
    String periodId,
    String barberId,
  ) async {
    try {
      final result = await remoteDataSource.getMyResult(periodId, barberId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>?>> getBarberTopPositions(
    String barberId,
  ) async {
    try {
      final result = await remoteDataSource.getBarberTopPositions(barberId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getHelpRules() async {
    try {
      final list = await remoteDataSource.getHelpRules();
      return Right(list);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
