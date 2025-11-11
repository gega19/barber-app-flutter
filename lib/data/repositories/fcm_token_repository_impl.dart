import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/logger.dart';
import '../../domain/repositories/fcm_token_repository.dart';
import '../datasources/remote/fcm_token_remote_datasource.dart';

class FcmTokenRepositoryImpl implements FcmTokenRepository {
  final FcmTokenRemoteDataSource remoteDataSource;

  FcmTokenRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, void>> registerToken({
    required String token,
    required String deviceType,
  }) async {
    try {
      await remoteDataSource.registerToken(
        token: token,
        deviceType: deviceType,
      );
      return const Right(null);
    } on ServerException catch (e) {
      appLogger.e('RegisterToken error: ${e.message}');
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      appLogger.e('RegisterToken network error: ${e.message}');
      return Left(NetworkFailure(e.message));
    } catch (e) {
      appLogger.e('RegisterToken unexpected error: $e', error: e);
      return Left(ServerFailure('Error inesperado al registrar token'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteToken(String token) async {
    try {
      await remoteDataSource.deleteToken(token);
      return const Right(null);
    } on ServerException catch (e) {
      appLogger.e('DeleteToken error: ${e.message}');
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      appLogger.e('DeleteToken network error: ${e.message}');
      return Left(NetworkFailure(e.message));
    } catch (e) {
      appLogger.e('DeleteToken unexpected error: $e', error: e);
      return Left(ServerFailure('Error inesperado al eliminar token'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUserTokens() async {
    try {
      await remoteDataSource.deleteUserTokens();
      return const Right(null);
    } on ServerException catch (e) {
      appLogger.e('DeleteUserTokens error: ${e.message}');
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      appLogger.e('DeleteUserTokens network error: ${e.message}');
      return Left(NetworkFailure(e.message));
    } catch (e) {
      appLogger.e('DeleteUserTokens unexpected error: $e', error: e);
      return Left(ServerFailure('Error inesperado al eliminar tokens'));
    }
  }
}

