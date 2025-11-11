import '../entities/workplace_entity.dart';
import '../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

abstract class WorkplaceRepository {
  Future<Either<Failure, List<WorkplaceEntity>>> getWorkplaces({int? limit});
  Future<Either<Failure, WorkplaceEntity>> getWorkplaceById(String id);
}
