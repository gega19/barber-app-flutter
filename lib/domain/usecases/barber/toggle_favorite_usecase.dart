import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/barber_repository.dart';

class ToggleFavoriteUseCase {
  final BarberRepository repository;

  ToggleFavoriteUseCase(this.repository);

  Future<Either<Failure, void>> call(String barberId) {
    return repository.toggleFavorite(barberId);
  }
}
