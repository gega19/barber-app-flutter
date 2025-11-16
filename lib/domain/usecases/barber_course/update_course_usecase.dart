import '../../entities/barber_course_entity.dart';
import '../../repositories/barber_course_repository.dart';
import '../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class UpdateCourseUseCase {
  final BarberCourseRepository repository;

  UpdateCourseUseCase(this.repository);

  Future<Either<Failure, BarberCourseEntity>> call(String id, {
    String? title,
    String? institution,
    String? description,
    DateTime? completedAt,
    String? duration,
  }) async {
    return await repository.updateCourse(
      id,
      title: title,
      institution: institution,
      description: description,
      completedAt: completedAt,
      duration: duration,
    );
  }
}

