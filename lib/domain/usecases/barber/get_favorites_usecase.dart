import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/barber_entity.dart';
import '../../repositories/barber_repository.dart';

class GetFavoritesUseCase {
  final BarberRepository repository;

  GetFavoritesUseCase(this.repository);

  Future<Either<Failure, List<BarberEntity>>> call() {
    return repository.getFavorites();
  }
}
