import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/review_repository.dart';
import '../../core/errors/failures.dart';
import '../datasources/remote/review_remote_datasource.dart';
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

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;

  ReviewRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<ReviewEntity>>> getReviewsByBarber(String barberId) async {
    try {
      final reviews = await remoteDataSource.getReviewsByBarber(barberId);
      return Right(reviews);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getReviewsByWorkplace(String workplaceId) async {
    try {
      final reviews = await remoteDataSource.getReviewsByWorkplace(workplaceId);
      return Right(reviews);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReviewEntity>> createReview({
    String? barberId,
    String? workplaceId,
    required int rating,
    String? comment,
  }) async {
    try {
      final review = await remoteDataSource.createReview(
        barberId: barberId,
        workplaceId: workplaceId,
        rating: rating,
        comment: comment,
      );
      return Right(review);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> hasUserReviewedBarber(String barberId) async {
    try {
      final hasReviewed = await remoteDataSource.hasUserReviewedBarber(barberId);
      return Right(hasReviewed);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> hasUserReviewedWorkplace(String workplaceId) async {
    try {
      final hasReviewed = await remoteDataSource.hasUserReviewedWorkplace(workplaceId);
      return Right(hasReviewed);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

