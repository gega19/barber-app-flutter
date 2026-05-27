import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/usecases/barber/get_favorites_usecase.dart';
import '../../../../domain/usecases/barber/toggle_favorite_usecase.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final GetFavoritesUseCase getFavoritesUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;

  FavoritesCubit({
    required this.getFavoritesUseCase,
    required this.toggleFavoriteUseCase,
  }) : super(FavoritesInitial());

  void clearSession() {
    emit(FavoritesInitial());
  }

  Future<void> loadFavorites() async {
    emit(FavoritesLoading());
    final result = await getFavoritesUseCase();
    result.fold(
      (failure) => emit(FavoritesError(failure.message)),
      (favorites) => emit(FavoritesLoaded(favorites)),
    );
  }

  Future<void> toggleFavorite(String barberId) async {
    // Current state check for optimistic update or just refresh
    // For simplicity, we call API then refresh list.
    // Ideally we optimistically update but if we fail revert.

    // We don't emit Loading here directly because it might flicker.
    // But we need to update the list.

    final result = await toggleFavoriteUseCase(barberId);

    result.fold(
      (failure) {
        // Show error? For now just emit error state if critical, or use a side effect stream.
        // We'll just emit Error so UI shows it.
        emit(FavoritesError(failure.message));
        // Reload to restore valid state
        loadFavorites();
      },
      (_) {
        // Success. Reload favorites.
        loadFavorites();
      },
    );
  }
}
