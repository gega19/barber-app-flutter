import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/barber_entity.dart';
import '../../../domain/usecases/barber/get_barbers_usecase.dart';
import '../../../domain/usecases/barber/get_best_barbers_usecase.dart';
import '../../../domain/usecases/barber/search_barbers_usecase.dart';

part 'barber_state.dart';

class BarberCubit extends Cubit<BarberState> {
  final GetBarbersUseCase getBarbersUseCase;
  final GetBestBarbersUseCase getBestBarbersUseCase;
  final SearchBarbersUseCase searchBarbersUseCase;

  BarberCubit({
    required this.getBarbersUseCase,
    required this.getBestBarbersUseCase,
    required this.searchBarbersUseCase,
  }) : super(BarberInitial());

  Future<void> loadBarbers() async {
    emit(BarberLoading());

    final result = await getBarbersUseCase();

    result.fold(
      (failure) => emit(BarberError(failure.message)),
      (barbers) => emit(BarberLoaded(barbers)),
    );
  }

  Future<void> loadBestBarbers({int limit = 10}) async {
    emit(BarberLoading());

    final result = await getBestBarbersUseCase(limit: limit);

    result.fold(
      (failure) => emit(BarberError(failure.message)),
      (barbers) => emit(BarberLoaded(barbers)),
    );
  }

  Future<void> searchBarbers(String query) async {
    if (query.isEmpty) {
      loadBestBarbers();
      return;
    }

    emit(BarberLoading());

    final result = await searchBarbersUseCase(query);

    result.fold(
      (failure) => emit(BarberError(failure.message)),
      (barbers) => emit(BarberLoaded(barbers)),
    );
  }

  void clearSearch() {
    loadBestBarbers();
  }
}


