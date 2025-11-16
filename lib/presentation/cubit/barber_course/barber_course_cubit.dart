import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/barber_course_entity.dart';
import '../../../domain/usecases/barber_course/get_barber_courses_usecase.dart';
import '../../../domain/usecases/barber_course/get_course_by_id_usecase.dart';
import '../../../domain/usecases/barber_course/create_course_usecase.dart';
import '../../../domain/usecases/barber_course/update_course_usecase.dart';
import '../../../domain/usecases/barber_course/delete_course_usecase.dart';

part 'barber_course_state.dart';

class BarberCourseCubit extends Cubit<BarberCourseState> {
  final GetBarberCoursesUseCase getBarberCoursesUseCase;
  final GetCourseByIdUseCase getCourseByIdUseCase;
  final CreateCourseUseCase createCourseUseCase;
  final UpdateCourseUseCase updateCourseUseCase;
  final DeleteCourseUseCase deleteCourseUseCase;

  BarberCourseCubit({
    required this.getBarberCoursesUseCase,
    required this.getCourseByIdUseCase,
    required this.createCourseUseCase,
    required this.updateCourseUseCase,
    required this.deleteCourseUseCase,
  }) : super(BarberCourseInitial());

  Future<void> loadCourses(String barberId) async {
    if (isClosed) return;
    emit(BarberCourseLoading());

    final result = await getBarberCoursesUseCase(barberId);

    if (isClosed) return;

    result.fold(
      (failure) {
        if (!isClosed) emit(BarberCourseError(failure.message));
      },
      (courses) {
        if (!isClosed) emit(BarberCourseLoaded(courses));
      },
    );
  }

  Future<void> loadCourseById(String id) async {
    if (isClosed) return;
    emit(BarberCourseLoading());

    final result = await getCourseByIdUseCase(id);

    if (isClosed) return;

    result.fold(
      (failure) {
        if (!isClosed) emit(BarberCourseError(failure.message));
      },
      (course) {
        // Si tenemos cursos cargados, actualizar la lista
        if (state is BarberCourseLoaded) {
          final currentState = state as BarberCourseLoaded;
          final updatedCourses = currentState.courses.map((c) {
            return c.id == course.id ? course : c;
          }).toList();
          if (!isClosed) emit(BarberCourseLoaded(updatedCourses));
        } else {
          if (!isClosed) emit(BarberCourseLoaded([course]));
        }
      },
    );
  }

  Future<bool> createCourse(String barberId, {
    required String title,
    String? institution,
    String? description,
    DateTime? completedAt,
    String? duration,
  }) async {
    if (isClosed) return false;
    emit(BarberCourseCreating());

    final result = await createCourseUseCase(
      barberId,
      title: title,
      institution: institution,
      description: description,
      completedAt: completedAt,
      duration: duration,
    );

    if (isClosed) return false;

    return result.fold(
      (failure) {
        if (!isClosed) emit(BarberCourseError(failure.message));
        return false;
      },
      (course) {
        if (!isClosed) {
          emit(BarberCourseCreated(course));
          // No recargar automáticamente - dejar que la UI lo maneje
          // Esto evita race conditions y permite que la UI capture el estado
        }
        return true;
      },
    );
  }

  Future<bool> updateCourse(String id, String barberId, {
    String? title,
    String? institution,
    String? description,
    DateTime? completedAt,
    String? duration,
  }) async {
    if (isClosed) return false;
    emit(BarberCourseUpdating());

    final result = await updateCourseUseCase(
      id,
      title: title,
      institution: institution,
      description: description,
      completedAt: completedAt,
      duration: duration,
    );

    if (isClosed) return false;

    return result.fold(
      (failure) {
        if (!isClosed) emit(BarberCourseError(failure.message));
        return false;
      },
      (course) {
        if (!isClosed) {
          emit(BarberCourseUpdated(course));
          // No recargar automáticamente - dejar que la UI lo maneje
        }
        return true;
      },
    );
  }

  Future<bool> deleteCourse(String id, String barberId) async {
    if (isClosed) return false;
    emit(BarberCourseDeleting());

    final result = await deleteCourseUseCase(id);

    if (isClosed) return false;

    return result.fold(
      (failure) {
        if (!isClosed) emit(BarberCourseError(failure.message));
        return false;
      },
      (_) {
        if (!isClosed) {
          emit(BarberCourseDeleted());
          // No recargar automáticamente - dejar que la UI lo maneje
        }
        return true;
      },
    );
  }
}

