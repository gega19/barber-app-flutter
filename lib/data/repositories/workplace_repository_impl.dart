import '../../domain/entities/workplace_entity.dart';
import '../../domain/entities/workplace_list_result.dart';
import '../../domain/repositories/workplace_repository.dart';
import '../../core/errors/failures.dart';
import '../datasources/remote/workplace_remote_datasource.dart';
import 'package:dartz/dartz.dart';

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => message;
}

class WorkplaceRepositoryImpl implements WorkplaceRepository {
  final WorkplaceRemoteDataSource remoteDataSource;

  WorkplaceRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<WorkplaceEntity>>> getWorkplaces({
    int? limit,
  }) async {
    try {
      final workplaces = await remoteDataSource.getWorkplaces(limit: limit);
      return Right(workplaces);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WorkplaceListResult>> getBestWorkplacesWithTotal({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final result = await remoteDataSource.getBestWorkplacesWithMetadata(
        limit: limit,
        offset: offset,
      );
      final list = result['workplaces'] as List;
      final total = result['total'] as int;
      return Right(
        WorkplaceListResult(
          workplaces: List<WorkplaceEntity>.from(list),
          total: total,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WorkplaceEntity>>> searchWorkplaces(
    String query,
  ) async {
    try {
      final workplaces = await remoteDataSource.searchWorkplaces(query);
      return Right(workplaces);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WorkplaceEntity>> getWorkplaceById(String id) async {
    try {
      final workplace = await remoteDataSource.getWorkplaceById(id);
      return Right(workplace);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WorkplaceEntity>>> getNearbyWorkplaces({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  }) async {
    try {
      final workplaces = await remoteDataSource.getNearbyWorkplaces(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );
      return Right(workplaces);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
