import '../../entities/review_entity.dart';
import '../../repositories/review_repository.dart';
import '../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class GetReviewsByBarberUseCase {
  final ReviewRepository repository;

  GetReviewsByBarberUseCase(this.repository);

  Future<Either<Failure, List<ReviewEntity>>> call(String barberId) async {
    return await repository.getReviewsByBarber(barberId);
  }
}

