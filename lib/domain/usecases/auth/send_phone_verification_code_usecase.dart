import '../../repositories/auth_repository.dart';
import '../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class SendPhoneVerificationCodeUseCase {
  final AuthRepository repository;

  SendPhoneVerificationCodeUseCase(this.repository);

  Future<Either<Failure, bool>> call(String phone) async {
    return await repository.sendPhoneVerificationCode(phone);
  }
}
