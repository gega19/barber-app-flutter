import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/review_repository.dart';

class HasUserReviewedWorkplaceUseCase {
  final ReviewRepository repository;

  HasUserReviewedWorkplaceUseCase(this.repository);

  Future<Either<Failure, bool>> call(String workplaceId) async {
    return await repository.hasUserReviewedWorkplace(workplaceId);
  }
}

