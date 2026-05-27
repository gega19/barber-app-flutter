import '../../entities/barber_list_result.dart';
import '../../repositories/barber_repository.dart';
import '../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class GetBestBarbersWithTotalUseCase {
  final BarberRepository repository;

  GetBestBarbersWithTotalUseCase(this.repository);

  Future<Either<Failure, BarberListResult>> call({
    int limit = 10,
    int offset = 0,
    String? country,
  }) async {
    return await repository.getBestBarbersWithTotal(
      limit: limit,
      offset: offset,
      country: country,
    );
  }
}
