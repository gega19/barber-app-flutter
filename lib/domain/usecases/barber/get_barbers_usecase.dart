import '../../entities/barber_entity.dart';
import '../../repositories/barber_repository.dart';
import '../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

/// Caso de uso para obtener barberos
class GetBarbersUseCase {
  final BarberRepository repository;

  GetBarbersUseCase(this.repository);

  Future<Either<Failure, List<BarberEntity>>> call() async {
    return await repository.getBarbers();
  }
}


