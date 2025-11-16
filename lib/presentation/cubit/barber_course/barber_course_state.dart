part of 'barber_course_cubit.dart';

abstract class BarberCourseState extends Equatable {
  const BarberCourseState();

  @override
  List<Object?> get props => [];
}

class BarberCourseInitial extends BarberCourseState {}

class BarberCourseLoading extends BarberCourseState {}

class BarberCourseLoaded extends BarberCourseState {
  final List<BarberCourseEntity> courses;

  const BarberCourseLoaded(this.courses);

  @override
  List<Object?> get props => [courses];
}

class BarberCourseError extends BarberCourseState {
  final String message;

  const BarberCourseError(this.message);

  @override
  List<Object?> get props => [message];
}

class BarberCourseCreating extends BarberCourseState {}

class BarberCourseCreated extends BarberCourseState {
  final BarberCourseEntity course;

  const BarberCourseCreated(this.course);

  @override
  List<Object?> get props => [course];
}

class BarberCourseUpdating extends BarberCourseState {}

class BarberCourseUpdated extends BarberCourseState {
  final BarberCourseEntity course;

  const BarberCourseUpdated(this.course);

  @override
  List<Object?> get props => [course];
}

class BarberCourseDeleting extends BarberCourseState {}

class BarberCourseDeleted extends BarberCourseState {}
