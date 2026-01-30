import '../../domain/entities/barber_entity.dart';
import '../../domain/entities/barber_list_result.dart';
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
  Future<Either<Failure, List<BarberEntity>>> getBestBarbers({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final barbers = await remoteDataSource.getBestBarbers(
        limit: limit,
        offset: offset,
      );
      return Right(barbers);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BarberListResult>> getBestBarbersWithTotal({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final result = await remoteDataSource.getBestBarbersWithMetadata(
        limit: limit,
        offset: offset,
      );
      final barbers = result['barbers'] as List<BarberEntity>;
      final total = result['total'] as int? ?? barbers.length;
      return Right(BarberListResult(barbers: barbers, total: total));
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
  Future<Either<Failure, List<BarberEntity>>> getBarbersByWorkplaceId(
    String workplaceId,
  ) async {
    try {
      final barbers = await remoteDataSource.getBarbersByWorkplaceId(
        workplaceId,
      );
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
          .where(
            (barber) =>
                barber.specialty.toLowerCase().contains(category.toLowerCase()),
          )
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

  @override
  Future<Either<Failure, void>> toggleFavorite(String barberId) async {
    try {
      await remoteDataSource.toggleFavorite(barberId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BarberEntity>>> getFavorites() async {
    try {
      final barbers = await remoteDataSource.getFavorites();
      return Right(barbers);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BarberEntity>> getBarberBySlug(String slug) async {
    try {
      final barber = await remoteDataSource.getBarberBySlug(slug);
      return Right(barber);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
