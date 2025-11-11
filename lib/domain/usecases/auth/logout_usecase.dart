import '../../repositories/auth_repository.dart';
import '../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.logout();
  }
}

