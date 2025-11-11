import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/review_entity.dart';
import '../../repositories/review_repository.dart';

class CreateReviewUseCase {
  final ReviewRepository repository;

  CreateReviewUseCase(this.repository);

  Future<Either<Failure, ReviewEntity>> call({
    String? barberId,
    String? workplaceId,
    required int rating,
    String? comment,
  }) async {
    return await repository.createReview(
      barberId: barberId,
      workplaceId: workplaceId,
      rating: rating,
      comment: comment,
    );
  }
}

