import '../../entities/review_entity.dart';
import '../../repositories/review_repository.dart';
import '../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class GetReviewsByWorkplaceUseCase {
  final ReviewRepository repository;

  GetReviewsByWorkplaceUseCase(this.repository);

  Future<Either<Failure, List<ReviewEntity>>> call(String workplaceId) async {
    return await repository.getReviewsByWorkplace(workplaceId);
  }
}

