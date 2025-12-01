part of 'map_cubit.dart';

abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapLoaded extends MapState {
  final List<WorkplaceEntity> workplaces;
  final Position? userLocation;
  final String? selectedWorkplaceId;
  // Filtros y búsqueda
  final String searchQuery;
  final double? minRating;
  final String? selectedCity;
  // Valores calculados (memoizados)
  final List<WorkplaceEntity> filteredWorkplaces;
  final List<String> availableCities;

  const MapLoaded({
    required this.workplaces,
    this.userLocation,
    this.selectedWorkplaceId,
    this.searchQuery = '',
    this.minRating,
    this.selectedCity,
    List<WorkplaceEntity>? filteredWorkplaces,
    List<String>? availableCities,
  }) : filteredWorkplaces = filteredWorkplaces ?? workplaces,
       availableCities = availableCities ?? const [];

  @override
  List<Object?> get props => [
    workplaces,
    userLocation,
    selectedWorkplaceId,
    searchQuery,
    minRating,
    selectedCity,
    filteredWorkplaces,
    availableCities,
  ];

  MapLoaded copyWith({
    List<WorkplaceEntity>? workplaces,
    Position? userLocation,
    String? selectedWorkplaceId,
    bool clearSelectedWorkplace = false,
    String? searchQuery,
    double? minRating,
    String? selectedCity,
    bool clearFilters = false,
    bool clearMinRating = false,
    List<WorkplaceEntity>? filteredWorkplaces,
    List<String>? availableCities,
    bool recalculateFilters = false,
  }) {
    final newWorkplaces = workplaces ?? this.workplaces;
    final newSearchQuery = clearFilters
        ? ''
        : (searchQuery ?? this.searchQuery);
    final newMinRating = clearFilters || clearMinRating
        ? null
        : (minRating ?? this.minRating);
    final newSelectedCity = clearFilters
        ? null
        : (selectedCity ?? this.selectedCity);

    // Recalcular filtros si es necesario
    final newFilteredWorkplaces =
        recalculateFilters ||
            workplaces != null ||
            searchQuery != null ||
            minRating != null ||
            selectedCity != null
        ? _calculateFilteredWorkplaces(
            newWorkplaces,
            newSearchQuery,
            newMinRating,
            newSelectedCity,
          )
        : (filteredWorkplaces ?? this.filteredWorkplaces);

    // Recalcular ciudades disponibles si cambian las barberías
    final newAvailableCities = workplaces != null
        ? _calculateAvailableCities(newWorkplaces)
        : (availableCities ?? this.availableCities);

    return MapLoaded(
      workplaces: newWorkplaces,
      userLocation: userLocation ?? this.userLocation,
      selectedWorkplaceId: clearSelectedWorkplace
          ? null
          : (selectedWorkplaceId ?? this.selectedWorkplaceId),
      searchQuery: newSearchQuery,
      minRating: newMinRating,
      selectedCity: newSelectedCity,
      filteredWorkplaces: newFilteredWorkplaces,
      availableCities: newAvailableCities,
    );
  }

  /// Calcula las barberías filtradas basado en los filtros activos
  static List<WorkplaceEntity> _calculateFilteredWorkplaces(
    List<WorkplaceEntity> workplaces,
    String searchQuery,
    double? minRating,
    String? selectedCity,
  ) {
    var filtered = List<WorkplaceEntity>.from(workplaces);

    // Filtro de búsqueda por texto
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((wp) {
        return wp.name.toLowerCase().contains(query) ||
            (wp.address?.toLowerCase().contains(query) ?? false) ||
            (wp.city?.toLowerCase().contains(query) ?? false) ||
            (wp.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Filtro por rating mínimo
    if (minRating != null && minRating > 0) {
      filtered = filtered.where((wp) => wp.rating >= minRating).toList();
    }

    // Filtro por ciudad
    if (selectedCity != null && selectedCity.isNotEmpty) {
      filtered = filtered
          .where((wp) => wp.city?.toLowerCase() == selectedCity.toLowerCase())
          .toList();
    }

    return filtered;
  }

  /// Calcula la lista de ciudades disponibles
  static List<String> _calculateAvailableCities(
    List<WorkplaceEntity> workplaces,
  ) {
    return workplaces
        .where((wp) => wp.city != null && wp.city!.isNotEmpty)
        .map((wp) => wp.city!)
        .toSet()
        .toList()
      ..sort();
  }
}

/// Tipos de errores del mapa
enum MapErrorType {
  permissionDenied,
  locationUnavailable,
  networkError,
  unknown,
}

class MapError extends MapState {
  final String message;
  final MapErrorType type;

  const MapError(this.message, {this.type = MapErrorType.unknown});

  @override
  List<Object?> get props => [message, type];
}
