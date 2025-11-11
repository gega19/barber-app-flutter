import '../../domain/entities/barber_entity.dart';
import '../../domain/repositories/barber_repository.dart';
import '../../core/errors/failures.dart';
import '../datasources/remote/barber_remote_datasource.dart';
import 'package:dartz/dartz.dart';

class BarberRepositoryImpl implements BarberRepository {
  final BarberRemoteDataSource remoteDataSource;

  BarberRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<BarberEntity>>> getBarbers() async {
    try {
      final barbers = await remoteDataSource.getBarbers();
      return Right(barbers);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BarberEntity>>> getBestBarbers({int limit = 10}) async {
    try {
      final barbers = await remoteDataSource.getBestBarbers(limit: limit);
      return Right(barbers);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BarberEntity>> getBarberById(String id) async {
    try {
      final barber = await remoteDataSource.getBarberById(id);
      return Right(barber);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BarberEntity>>> searchBarbers(
    String query,
  ) async {
    try {
      final barbers = await remoteDataSource.searchBarbers(query);
      return Right(barbers);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BarberEntity>>> getBarbersByCategory(
    String category,
  ) async {
    try {
      final allBarbers = await remoteDataSource.getBarbers();
      final filtered = allBarbers
          .where((barber) => barber.specialty.toLowerCase().contains(
                category.toLowerCase(),
              ))
          .toList();
      return Right(filtered);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BarberEntity>>> getTrendingBarbers() async {
    try {
      final allBarbers = await remoteDataSource.getBarbers();
      final trendingBarbers = allBarbers.toList()
        ..sort((a, b) {
          final scoreA = a.rating * a.reviews;
          final scoreB = b.rating * b.reviews;
          return scoreB.compareTo(scoreA);
        });
      return Right(trendingBarbers.take(3).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

