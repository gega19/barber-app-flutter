import '../../entities/barber_entity.dart';
import '../../repositories/barber_repository.dart';
import '../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class GetBestBarbersUseCase {
  final BarberRepository repository;

  GetBestBarbersUseCase(this.repository);

  Future<Either<Failure, List<BarberEntity>>> call({int limit = 10}) async {
    return await repository.getBestBarbers(limit: limit);
  }
}
