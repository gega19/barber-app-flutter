import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/workplace_entity.dart';
import '../../../domain/usecases/workplace/get_workplaces_usecase.dart';

part 'workplace_state.dart';

class WorkplaceCubit extends Cubit<WorkplaceState> {
  final GetWorkplacesUseCase getWorkplacesUseCase;

  WorkplaceCubit({
    required this.getWorkplacesUseCase,
  }) : super(WorkplaceInitial());

  Future<void> loadWorkplaces({int? limit}) async {
    emit(WorkplaceLoading());

    final result = await getWorkplacesUseCase(limit: limit);

    result.fold(
      (failure) => emit(WorkplaceError(failure.message)),
      (workplaces) => emit(WorkplaceLoaded(workplaces)),
    );
  }
}
