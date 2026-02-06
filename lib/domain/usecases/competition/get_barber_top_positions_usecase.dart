import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/competition_repository.dart';

class GetBarberTopPositionsUseCase {
  final CompetitionRepository repository;

  GetBarberTopPositionsUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>?>> call(String barberId) {
    return repository.getBarberTopPositions(barberId);
  }
}
