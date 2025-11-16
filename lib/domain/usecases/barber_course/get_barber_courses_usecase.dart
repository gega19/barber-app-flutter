import '../../entities/barber_course_entity.dart';
import '../../repositories/barber_course_repository.dart';
import '../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class GetBarberCoursesUseCase {
  final BarberCourseRepository repository;

  GetBarberCoursesUseCase(this.repository);

  Future<Either<Failure, List<BarberCourseEntity>>> call(String barberId) async {
    return await repository.getBarberCourses(barberId);
  }
}

