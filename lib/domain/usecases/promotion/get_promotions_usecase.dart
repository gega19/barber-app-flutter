import '../../entities/promotion_entity.dart';
import '../../repositories/promotion_repository.dart';
import '../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class GetPromotionsUseCase {
  final PromotionRepository repository;

  GetPromotionsUseCase(this.repository);

  Future<Either<Failure, List<PromotionEntity>>> call() async {
    return await repository.getPromotions();
  }
}

