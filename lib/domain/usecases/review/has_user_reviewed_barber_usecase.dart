import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/review_repository.dart';

class HasUserReviewedBarberUseCase {
  final ReviewRepository repository;

  HasUserReviewedBarberUseCase(this.repository);

  Future<Either<Failure, bool>> call(String barberId) async {
    return await repository.hasUserReviewedBarber(barberId);
  }
}

