part of 'workplace_cubit.dart';

abstract class WorkplaceState extends Equatable {
  const WorkplaceState();

  @override
  List<Object> get props => [];
}

class WorkplaceInitial extends WorkplaceState {}

class WorkplaceLoading extends WorkplaceState {}

class WorkplaceLoaded extends WorkplaceState {
  final List<WorkplaceEntity> workplaces;

  const WorkplaceLoaded(this.workplaces);

  @override
  List<Object> get props => [workplaces];
}

class WorkplaceError extends WorkplaceState {
  final String message;

  const WorkplaceError(this.message);

  @override
  List<Object> get props => [message];
}
