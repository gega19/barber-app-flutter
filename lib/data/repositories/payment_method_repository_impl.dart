import '../../domain/entities/payment_method_entity.dart';
import '../../domain/repositories/payment_method_repository.dart';
import '../../core/errors/failures.dart';
import '../datasources/remote/payment_method_remote_datasource.dart';
import 'package:dartz/dartz.dart';

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => message;
}

class PaymentMethodRepositoryImpl implements PaymentMethodRepository {
  final PaymentMethodRemoteDataSource remoteDataSource;

  PaymentMethodRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<PaymentMethodEntity>>> getPaymentMethods({String? barberId}) async {
    try {
      final paymentMethods = await remoteDataSource.getPaymentMethods(barberId: barberId);
      return Right(paymentMethods);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentMethodEntity>> getPaymentMethodWithConfig(String id) async {
    try {
      final paymentMethod = await remoteDataSource.getPaymentMethodWithConfig(id);
      return Right(paymentMethod);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PaymentMethodEntity>>> getBarberPaymentOptions(String barberId) async {
    try {
      final options = await remoteDataSource.getBarberPaymentOptions(barberId);
      return Right(options);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PaymentMethodEntity>>> getBarberPaymentTemplates(String barberId) async {
    try {
      final templates = await remoteDataSource.getBarberPaymentTemplates(barberId);
      return Right(templates);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentMethodEntity>> saveBarberPaymentOption({
    required String barberId,
    String? id,
    required String name,
    String? icon,
    Map<String, dynamic>? config,
    bool? isActive,
    String? templateId,
    int? sortOrder,
  }) async {
    try {
      final option = await remoteDataSource.saveBarberPaymentOption(
        barberId: barberId,
        id: id,
        name: name,
        icon: icon,
        config: config,
        isActive: isActive,
        templateId: templateId,
        sortOrder: sortOrder,
      );
      return Right(option);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setBarberPaymentOptionEnabled(
    String id, {
    required bool isActive,
  }) async {
    try {
      await remoteDataSource.setBarberPaymentOptionEnabled(id, isActive: isActive);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBarberPaymentOption(String id) async {
    try {
      await remoteDataSource.deleteBarberPaymentOption(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

