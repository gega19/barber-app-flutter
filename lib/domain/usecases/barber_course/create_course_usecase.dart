import '../../entities/barber_course_entity.dart';
import '../../repositories/barber_course_repository.dart';
import '../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class CreateCourseUseCase {
  final BarberCourseRepository repository;

  CreateCourseUseCase(this.repository);

  Future<Either<Failure, BarberCourseEntity>> call(String barberId, {
    required String title,
    String? institution,
    String? description,
    DateTime? completedAt,
    String? duration,
  }) async {
    return await repository.createCourse(
      barberId,
      title: title,
      institution: institution,
      description: description,
      completedAt: completedAt,
      duration: duration,
    );
  }
}

