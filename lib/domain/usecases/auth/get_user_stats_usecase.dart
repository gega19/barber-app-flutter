import '../../repositories/auth_repository.dart';
import '../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class GetUserStatsUseCase {
  final AuthRepository repository;

  GetUserStatsUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call() async {
    return await repository.getUserStats();
  }
}

