import '../entities/promotion_entity.dart';
import '../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

abstract class PromotionRepository {
  Future<Either<Failure, List<PromotionEntity>>> getPromotions();
  Future<Either<Failure, List<PromotionEntity>>> getPromotionsByBarber(String barberId);
  Future<Either<Failure, PromotionEntity?>> getPromotionById(String id);
}

