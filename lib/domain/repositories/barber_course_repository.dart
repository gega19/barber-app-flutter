import '../entities/barber_course_entity.dart';
import '../entities/barber_course_media_entity.dart';
import '../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

/// Interfaz del repositorio de cursos de barbero
abstract class BarberCourseRepository {
  /// Obtiene todos los cursos de un barbero
  Future<Either<Failure, List<BarberCourseEntity>>> getBarberCourses(String barberId);

  /// Obtiene un curso por ID
  Future<Either<Failure, BarberCourseEntity>> getCourseById(String id);

  /// Crea un nuevo curso
  Future<Either<Failure, BarberCourseEntity>> createCourse(String barberId, {
    required String title,
    String? institution,
    String? description,
    DateTime? completedAt,
    String? duration,
  });

  /// Actualiza un curso
  Future<Either<Failure, BarberCourseEntity>> updateCourse(String id, {
    String? title,
    String? institution,
    String? description,
    DateTime? completedAt,
    String? duration,
  });

  /// Elimina un curso
  Future<Either<Failure, void>> deleteCourse(String id);

  /// Obtiene el media de un curso
  Future<Either<Failure, List<BarberCourseMediaEntity>>> getCourseMedia(String courseId);

  /// Obtiene un media por ID
  Future<Either<Failure, BarberCourseMediaEntity>> getCourseMediaById(String id);

  /// Crea media para un curso
  Future<Either<Failure, BarberCourseMediaEntity>> createCourseMedia(String courseId, {
    required String type,
    required String url,
    String? thumbnail,
    String? caption,
  });

  /// Crea múltiples media para un curso
  Future<Either<Failure, List<BarberCourseMediaEntity>>> createMultipleCourseMedia(String courseId, List<Map<String, dynamic>> mediaItems);

  /// Actualiza media de un curso
  Future<Either<Failure, BarberCourseMediaEntity>> updateCourseMedia(String id, {
    String? caption,
    String? thumbnail,
  });

  /// Elimina media de un curso
  Future<Either<Failure, void>> deleteCourseMedia(String id);
}

