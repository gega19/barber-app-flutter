import '../../domain/entities/barber_availability_entity.dart';
import '../../domain/repositories/barber_availability_repository.dart';
import '../../core/errors/failures.dart';
import '../datasources/remote/barber_availability_remote_datasource.dart';
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

class BarberAvailabilityRepositoryImpl implements BarberAvailabilityRepository {
  final BarberAvailabilityRemoteDataSource remoteDataSource;

  BarberAvailabilityRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<BarberAvailabilityEntity>>> getMyAvailability() async {
    try {
      final availability = await remoteDataSource.getMyAvailability();
      return Right(availability);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BarberAvailabilityEntity>>> updateMyAvailability(
    List<Map<String, dynamic>> availability,
  ) async {
    try {
      final updatedAvailability = await remoteDataSource.updateMyAvailability(availability);
      return Right(updatedAvailability);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAvailableSlots(String barberId, String date) async {
    try {
      final slots = await remoteDataSource.getAvailableSlots(barberId, date);
      return Right(slots);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

