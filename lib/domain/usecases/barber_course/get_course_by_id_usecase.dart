import '../../entities/barber_course_entity.dart';
import '../../repositories/barber_course_repository.dart';
import '../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class GetCourseByIdUseCase {
  final BarberCourseRepository repository;

  GetCourseByIdUseCase(this.repository);

  Future<Either<Failure, BarberCourseEntity>> call(String id) async {
    return await repository.getCourseById(id);
  }
}

