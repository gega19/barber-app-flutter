import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import '../../../domain/entities/workplace_entity.dart';
import '../../../domain/usecases/workplace/get_workplaces_usecase.dart';
import '../../../domain/usecases/workplace/get_nearby_workplaces_usecase.dart';
import '../../../core/services/location_service.dart';

part 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  final GetWorkplacesUseCase getWorkplacesUseCase;
  final GetNearbyWorkplacesUseCase getNearbyWorkplacesUseCase;
  final LocationService locationService;

  MapCubit({
    required this.getWorkplacesUseCase,
    required this.getNearbyWorkplacesUseCase,
    required this.locationService,
  }) : super(MapInitial());

  /// Carga todas las barberías
  Future<void> loadWorkplaces({bool showLoading = true}) async {
    if (isClosed) return;

    final currentState = state;
    if (showLoading && currentState is! MapLoaded) {
      emit(MapLoading());
    }

    final result = await getWorkplacesUseCase();

    if (isClosed) return;

    result.fold(
      (failure) {
        if (!isClosed) {
          // Determinar tipo de error basado en el mensaje
          final errorMessage = failure.message.toLowerCase();
          MapErrorType errorType = MapErrorType.unknown;
          if (errorMessage.contains('network') ||
              errorMessage.contains('connection')) {
            errorType = MapErrorType.networkError;
          }
          emit(MapError(failure.message, type: errorType));
        }
      },
      (workplaces) {
        if (!isClosed) {
          final currentState = state;
          if (currentState is MapLoaded) {
            // Preservar todos los filtros actuales
            emit(currentState.copyWith(workplaces: workplaces));
          } else {
            emit(MapLoaded(workplaces: workplaces));
          }
        }
      },
    );
  }

  /// Carga barberías cercanas a una ubicación
  Future<void> loadNearbyWorkplaces({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
    bool showLoading = true,
  }) async {
    if (isClosed) return;

    final currentState = state;
    if (showLoading && currentState is! MapLoaded) {
      emit(MapLoading());
    }

    final result = await getNearbyWorkplacesUseCase(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );

    if (isClosed) return;

    result.fold(
      (failure) {
        if (!isClosed) {
          // Determinar tipo de error basado en el mensaje
          final errorMessage = failure.message.toLowerCase();
          MapErrorType errorType = MapErrorType.unknown;
          if (errorMessage.contains('network') ||
              errorMessage.contains('connection')) {
            errorType = MapErrorType.networkError;
          }
          emit(MapError(failure.message, type: errorType));
        }
      },
      (workplaces) {
        if (!isClosed) {
          final currentState = state;
          if (currentState is MapLoaded) {
            // Preservar todos los filtros actuales
            emit(currentState.copyWith(workplaces: workplaces));
          } else {
            emit(MapLoaded(workplaces: workplaces));
          }
        }
      },
    );
  }

  /// Obtiene la ubicación actual del usuario
  Future<void> getUserLocation() async {
    if (isClosed) return;

    try {
      final position = await locationService.getCurrentLocation();

      if (isClosed) return;

      if (position != null) {
        final currentState = state;
        if (currentState is MapLoaded) {
          emit(currentState.copyWith(userLocation: position));
          // Cargar todas las barberías
          await loadWorkplaces(showLoading: false);
        } else {
          emit(MapLoaded(workplaces: [], userLocation: position));
          // Cargar todas las barberías
          await loadWorkplaces(showLoading: false);
        }
      } else {
        // Si no se puede obtener ubicación, cargar todas las barberías
        await loadWorkplaces(showLoading: true);
      }
    } catch (e) {
      if (isClosed) return;
      // Determinar tipo de error
      final errorMessage = e.toString().toLowerCase();
      MapErrorType errorType = MapErrorType.unknown;
      if (errorMessage.contains('permission') ||
          errorMessage.contains('denied')) {
        errorType = MapErrorType.permissionDenied;
      } else if (errorMessage.contains('location') ||
          errorMessage.contains('unavailable')) {
        errorType = MapErrorType.locationUnavailable;
      } else if (errorMessage.contains('network') ||
          errorMessage.contains('connection')) {
        errorType = MapErrorType.networkError;
      }
      emit(
        MapError(
          'Error al obtener ubicación: ${e.toString()}',
          type: errorType,
        ),
      );
    }
  }

  /// Selecciona una barbería en el mapa
  void selectWorkplace(String? workplaceId) {
    if (isClosed) return;

    final currentState = state;
    if (currentState is MapLoaded) {
      emit(currentState.copyWith(selectedWorkplaceId: workplaceId));
    }
  }

  /// Deselecciona la barbería actual
  void deselectWorkplace() {
    if (isClosed) return;

    final currentState = state;
    if (currentState is MapLoaded) {
      // Usar copyWith con clearSelectedWorkplace para asegurar que se establezca en null
      emit(currentState.copyWith(clearSelectedWorkplace: true));
    }
  }

  /// Actualiza la búsqueda por texto
  void updateSearchQuery(String query) {
    if (isClosed) return;

    final currentState = state;
    if (currentState is MapLoaded) {
      emit(currentState.copyWith(searchQuery: query, recalculateFilters: true));
    }
  }

  /// Filtra por rating mínimo
  void filterByMinRating(double? minRating) {
    if (isClosed) return;

    final currentState = state;
    if (currentState is MapLoaded) {
      // Si minRating es null, usar clearMinRating para establecerlo explícitamente
      if (minRating == null) {
        emit(
          currentState.copyWith(clearMinRating: true, recalculateFilters: true),
        );
      } else {
        emit(
          currentState.copyWith(minRating: minRating, recalculateFilters: true),
        );
      }
    }
  }

  /// Filtra barberías por ciudad
  void filterByCity(String? city) {
    if (isClosed) return;

    final currentState = state;
    if (currentState is MapLoaded) {
      emit(currentState.copyWith(selectedCity: city, recalculateFilters: true));
    }
  }

  /// Limpia todos los filtros
  void clearFilters() {
    if (isClosed) return;

    final currentState = state;
    if (currentState is MapLoaded) {
      emit(currentState.copyWith(clearFilters: true, recalculateFilters: true));
      // Recargar todas las barberías
      loadWorkplaces(showLoading: false);
    }
  }

  /// Obtiene lista de ciudades únicas de las barberías (memoizada en el estado)
  List<String> getAvailableCities() {
    final currentState = state;
    if (currentState is MapLoaded) {
      return currentState.availableCities;
    }
    return [];
  }

  /// Obtiene la lista filtrada de barberías (memoizada en el estado)
  List<WorkplaceEntity> getFilteredWorkplaces() {
    final currentState = state;
    if (currentState is MapLoaded) {
      return currentState.filteredWorkplaces;
    }
    return [];
  }
}
