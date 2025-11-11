import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../../core/errors/failures.dart';
import '../datasources/remote/appointment_remote_datasource.dart';
import 'package:dartz/dartz.dart';

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDataSource remoteDataSource;

  AppointmentRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<AppointmentEntity>>> getAppointments() async {
    try {
      final appointments = await remoteDataSource.getAppointments();
      return Right(appointments);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppointmentEntity>> createAppointment({
    required String barberId,
    String? serviceId,
    required DateTime date,
    required String time,
    required String paymentMethod,
    String? paymentProof,
    String? notes,
  }) async {
    try {
      final appointment = await remoteDataSource.createAppointment(
        barberId: barberId,
        serviceId: serviceId,
        date: date,
        time: time,
        paymentMethod: paymentMethod,
        paymentProof: paymentProof,
        notes: notes,
      );
      return Right(appointment);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelAppointment(String appointmentId) async {
    return const Left(ServerFailure('Not implemented yet'));
  }

  @override
  Future<Either<Failure, void>> rateAppointment({
    required String appointmentId,
    required int rating,
    String? comment,
  }) async {
    return const Left(ServerFailure('Not implemented yet'));
  }
}
