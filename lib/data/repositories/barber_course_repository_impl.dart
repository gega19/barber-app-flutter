import '../../domain/entities/barber_course_entity.dart';
import '../../domain/entities/barber_course_media_entity.dart';
import '../../domain/repositories/barber_course_repository.dart';
import '../../core/errors/failures.dart';
import '../datasources/remote/barber_course_remote_datasource.dart';
import 'package:dartz/dartz.dart';

class BarberCourseRepositoryImpl implements BarberCourseRepository {
  final BarberCourseRemoteDataSource remoteDataSource;

  BarberCourseRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<BarberCourseEntity>>> getBarberCourses(String barberId) async {
    try {
      final courses = await remoteDataSource.getBarberCourses(barberId);
      return Right(courses);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BarberCourseEntity>> getCourseById(String id) async {
    try {
      final course = await remoteDataSource.getCourseById(id);
      return Right(course);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BarberCourseEntity>> createCourse(String barberId, {
    required String title,
    String? institution,
    String? description,
    DateTime? completedAt,
    String? duration,
  }) async {
    try {
      if (title.trim().length < 3) {
        return const Left(ValidationFailure('El título debe tener al menos 3 caracteres'));
      }

      final course = await remoteDataSource.createCourse(
        barberId,
        title: title.trim(),
        institution: institution?.trim(),
        description: description?.trim(),
        completedAt: completedAt,
        duration: duration?.trim(),
      );
      return Right(course);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BarberCourseEntity>> updateCourse(String id, {
    String? title,
    String? institution,
    String? description,
    DateTime? completedAt,
    String? duration,
  }) async {
    try {
      if (title != null && title.trim().length < 3) {
        return const Left(ValidationFailure('El título debe tener al menos 3 caracteres'));
      }

      final course = await remoteDataSource.updateCourse(
        id,
        title: title?.trim(),
        institution: institution?.trim(),
        description: description?.trim(),
        completedAt: completedAt,
        duration: duration?.trim(),
      );
      return Right(course);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCourse(String id) async {
    try {
      await remoteDataSource.deleteCourse(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BarberCourseMediaEntity>>> getCourseMedia(String courseId) async {
    try {
      final media = await remoteDataSource.getCourseMedia(courseId);
      return Right(media);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BarberCourseMediaEntity>> getCourseMediaById(String id) async {
    try {
      final media = await remoteDataSource.getCourseMediaById(id);
      return Right(media);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BarberCourseMediaEntity>> createCourseMedia(String courseId, {
    required String type,
    required String url,
    String? thumbnail,
    String? caption,
  }) async {
    try {
      if (type.isEmpty || url.isEmpty) {
        return const Left(ValidationFailure('Tipo y URL son requeridos'));
      }

      final media = await remoteDataSource.createCourseMedia(
        courseId,
        type: type,
        url: url,
        thumbnail: thumbnail,
        caption: caption,
      );
      return Right(media);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BarberCourseMediaEntity>>> createMultipleCourseMedia(String courseId, List<Map<String, dynamic>> mediaItems) async {
    try {
      if (mediaItems.isEmpty) {
        return const Left(ValidationFailure('Se requiere al menos un elemento de media'));
      }

      final media = await remoteDataSource.createMultipleCourseMedia(courseId, mediaItems);
      return Right(media);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BarberCourseMediaEntity>> updateCourseMedia(String id, {
    String? caption,
    String? thumbnail,
  }) async {
    try {
      final media = await remoteDataSource.updateCourseMedia(id, caption: caption, thumbnail: thumbnail);
      return Right(media);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCourseMedia(String id) async {
    try {
      await remoteDataSource.deleteCourseMedia(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

