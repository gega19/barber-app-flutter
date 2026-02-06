import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class ConfirmPhoneVerificationUseCase {
  final AuthRepository repository;

  ConfirmPhoneVerificationUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(String phone, String code) async {
    return await repository.confirmPhoneVerification(phone, code);
  }
}
