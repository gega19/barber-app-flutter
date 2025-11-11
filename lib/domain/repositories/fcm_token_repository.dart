import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';

abstract class FcmTokenRepository {
  Future<Either<Failure, void>> registerToken({
    required String token,
    required String deviceType,
  });

  Future<Either<Failure, void>> deleteToken(String token);

  Future<Either<Failure, void>> deleteUserTokens();
}

