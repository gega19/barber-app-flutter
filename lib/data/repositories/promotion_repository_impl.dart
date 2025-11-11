import '../../domain/entities/promotion_entity.dart';
import '../../domain/repositories/promotion_repository.dart';
import '../../core/errors/failures.dart';
import '../datasources/remote/promotion_remote_datasource.dart';
import 'package:dartz/dartz.dart';

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class PromotionRepositoryImpl implements PromotionRepository {
  final PromotionRemoteDataSource remoteDataSource;

  PromotionRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<PromotionEntity>>> getPromotions() async {
    try {
      final promotions = await remoteDataSource.getPromotions();
      return Right(promotions);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PromotionEntity?>> getPromotionById(String id) async {
    try {
      final promotion = await remoteDataSource.getPromotionById(id);
      return Right(promotion);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

