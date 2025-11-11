import '../entities/review_entity.dart';
import '../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

abstract class ReviewRepository {
  Future<Either<Failure, List<ReviewEntity>>> getReviewsByBarber(String barberId);
  Future<Either<Failure, List<ReviewEntity>>> getReviewsByWorkplace(String workplaceId);
  Future<Either<Failure, ReviewEntity>> createReview({
    String? barberId,
    String? workplaceId,
    required int rating,
    String? comment,
  });
  Future<Either<Failure, bool>> hasUserReviewedBarber(String barberId);
  Future<Either<Failure, bool>> hasUserReviewedWorkplace(String workplaceId);
}

