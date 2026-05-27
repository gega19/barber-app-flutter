import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class RefreshCurrentUserUseCase {
  final AuthRepository repository;

  RefreshCurrentUserUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call() async {
    return repository.refreshCurrentUser();
  }
}
