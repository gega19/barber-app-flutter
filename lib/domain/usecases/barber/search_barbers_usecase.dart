import '../../entities/barber_entity.dart';
import '../../repositories/barber_repository.dart';
import '../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

/// Caso de uso para buscar barberos
class SearchBarbersUseCase {
  final BarberRepository repository;

  SearchBarbersUseCase(this.repository);

  Future<Either<Failure, List<BarberEntity>>> call(String query) async {
    return await repository.searchBarbers(query);
  }
}


