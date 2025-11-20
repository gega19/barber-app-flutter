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
  Future<void> loadWorkplaces() async {
    if (isClosed) return;
    emit(MapLoading());

    final result = await getWorkplacesUseCase();

    if (isClosed) return;

    result.fold(
      (failure) {
        if (!isClosed) emit(MapError(failure.message));
      },
      (workplaces) {
        if (!isClosed) {
          emit(MapLoaded(workplaces: workplaces));
        }
      },
    );
  }

  /// Carga barberías cercanas a una ubicación
  Future<void> loadNearbyWorkplaces({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  }) async {
    if (isClosed) return;
    emit(MapLoading());

    final result = await getNearbyWorkplacesUseCase(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );

    if (isClosed) return;

    result.fold(
      (failure) {
        if (!isClosed) emit(MapError(failure.message));
      },
      (workplaces) {
        if (!isClosed) {
          final currentState = state;
          if (currentState is MapLoaded) {
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
          // Cargar barberías cercanas automáticamente
          await loadNearbyWorkplaces(
            latitude: position.latitude,
            longitude: position.longitude,
          );
        } else {
          emit(MapLoaded(
            workplaces: [],
            userLocation: position,
          ));
          // Cargar barberías cercanas automáticamente
          await loadNearbyWorkplaces(
            latitude: position.latitude,
            longitude: position.longitude,
          );
        }
      } else {
        // Si no se puede obtener ubicación, cargar todas las barberías
        await loadWorkplaces();
      }
    } catch (e) {
      if (isClosed) return;
      emit(MapError('Error al obtener ubicación: ${e.toString()}'));
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
      emit(currentState.copyWith(searchQuery: query));
    }
  }

  /// Filtra por rating mínimo
  void filterByMinRating(double? minRating) {
    if (isClosed) return;

    final currentState = state;
    if (currentState is MapLoaded) {
      emit(currentState.copyWith(minRating: minRating));
    }
  }

  /// Filtra por distancia máxima
  void filterByMaxDistance(double? maxDistanceKm) {
    if (isClosed) return;

    final currentState = state;
    if (currentState is MapLoaded) {
      emit(currentState.copyWith(maxDistanceKm: maxDistanceKm));
    }
  }

  /// Filtra barberías por ciudad
  void filterByCity(String? city) {
    if (isClosed) return;

    final currentState = state;
    if (currentState is MapLoaded) {
      emit(currentState.copyWith(selectedCity: city));
    }
  }

  /// Actualiza el radio de búsqueda y recarga barberías cercanas
  Future<void> updateSearchRadius(double radiusKm) async {
    if (isClosed) return;

    final currentState = state;
    if (currentState is MapLoaded && currentState.userLocation != null) {
      // Actualizar el radio en el estado
      emit(currentState.copyWith(searchRadiusKm: radiusKm));
      
      // Recargar barberías con el nuevo radio
      await loadNearbyWorkplaces(
        latitude: currentState.userLocation!.latitude,
        longitude: currentState.userLocation!.longitude,
        radiusKm: radiusKm,
      );
    }
  }

  /// Limpia todos los filtros
  void clearFilters() {
    if (isClosed) return;

    final currentState = state;
    if (currentState is MapLoaded) {
      emit(currentState.copyWith(clearFilters: true));
    }
  }

  /// Obtiene lista de ciudades únicas de las barberías
  List<String> getAvailableCities() {
    final currentState = state;
    if (currentState is MapLoaded) {
      return currentState.workplaces
          .where((wp) => wp.city != null && wp.city!.isNotEmpty)
          .map((wp) => wp.city!)
          .toSet()
          .toList()
        ..sort();
    }
    return [];
  }

  /// Obtiene la lista filtrada de barberías basada en los filtros activos
  List<WorkplaceEntity> getFilteredWorkplaces() {
    final currentState = state;
    if (currentState is! MapLoaded) return [];

    var filtered = List<WorkplaceEntity>.from(currentState.workplaces);

    // Filtro de búsqueda por texto
    if (currentState.searchQuery.isNotEmpty) {
      final query = currentState.searchQuery.toLowerCase();
      filtered = filtered.where((wp) {
        return wp.name.toLowerCase().contains(query) ||
            (wp.address?.toLowerCase().contains(query) ?? false) ||
            (wp.city?.toLowerCase().contains(query) ?? false) ||
            (wp.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Filtro por rating mínimo
    if (currentState.minRating != null && currentState.minRating! > 0) {
      filtered = filtered.where((wp) => wp.rating >= currentState.minRating!).toList();
    }

    // Filtro por ciudad
    if (currentState.selectedCity != null && currentState.selectedCity!.isNotEmpty) {
      filtered = filtered.where((wp) =>
          wp.city?.toLowerCase() == currentState.selectedCity!.toLowerCase()).toList();
    }

    // Filtro por distancia máxima (si hay ubicación del usuario)
    if (currentState.maxDistanceKm != null && currentState.userLocation != null) {
      filtered = filtered.where((wp) {
        if (wp.latitude == null || wp.longitude == null) return false;
        final distance = locationService.calculateDistance(
          currentState.userLocation!.latitude,
          currentState.userLocation!.longitude,
          wp.latitude!,
          wp.longitude!,
        );
        return distance <= currentState.maxDistanceKm!;
      }).toList();
    }

    return filtered;
  }
}

