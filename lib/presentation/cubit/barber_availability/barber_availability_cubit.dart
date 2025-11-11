import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/barber_availability_entity.dart';
import '../../../domain/usecases/barber_availability/get_my_availability_usecase.dart';
import '../../../domain/usecases/barber_availability/update_my_availability_usecase.dart';

part 'barber_availability_state.dart';

class BarberAvailabilityCubit extends Cubit<BarberAvailabilityState> {
  final GetMyAvailabilityUseCase getMyAvailabilityUseCase;
  final UpdateMyAvailabilityUseCase updateMyAvailabilityUseCase;

  BarberAvailabilityCubit({
    required this.getMyAvailabilityUseCase,
    required this.updateMyAvailabilityUseCase,
  }) : super(BarberAvailabilityInitial());

  Future<void> loadMyAvailability() async {
    emit(BarberAvailabilityLoading());

    final result = await getMyAvailabilityUseCase();

    result.fold(
      (failure) => emit(BarberAvailabilityError(failure.message)),
      (availability) => emit(BarberAvailabilityLoaded(availability)),
    );
  }

  Future<void> updateMyAvailability(List<Map<String, dynamic>> availability) async {
    final currentState = state;
    if (currentState is BarberAvailabilityLoaded) {
      emit(BarberAvailabilityUpdating(currentState.availability));
    }

    final result = await updateMyAvailabilityUseCase(availability);

    result.fold(
      (failure) {
        if (currentState is BarberAvailabilityLoaded) {
          emit(BarberAvailabilityLoaded(currentState.availability));
        }
        emit(BarberAvailabilityError(failure.message));
      },
      (availability) => emit(BarberAvailabilityUpdated(availability)),
    );
  }
}

