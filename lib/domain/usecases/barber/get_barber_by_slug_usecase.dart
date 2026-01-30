import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/barber_entity.dart';
import '../../repositories/barber_repository.dart';

class GetBarberBySlugUseCase {
  final BarberRepository repository;

  GetBarberBySlugUseCase(this.repository);

  Future<Either<Failure, BarberEntity>> call(String slug) {
    return repository.getBarberBySlug(slug);
  }
}
