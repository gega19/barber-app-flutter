import '../../repositories/barber_course_repository.dart';
import '../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class DeleteCourseUseCase {
  final BarberCourseRepository repository;

  DeleteCourseUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteCourse(id);
  }
}

