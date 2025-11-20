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
  final double? maxDistanceKm;
  final String? selectedCity;
  final double searchRadiusKm;

  const MapLoaded({
    required this.workplaces,
    this.userLocation,
    this.selectedWorkplaceId,
    this.searchQuery = '',
    this.minRating,
    this.maxDistanceKm,
    this.selectedCity,
    this.searchRadiusKm = 5.0,
  });

  @override
  List<Object?> get props => [
        workplaces,
        userLocation,
        selectedWorkplaceId,
        searchQuery,
        minRating,
        maxDistanceKm,
        selectedCity,
        searchRadiusKm,
      ];

  MapLoaded copyWith({
    List<WorkplaceEntity>? workplaces,
    Position? userLocation,
    String? selectedWorkplaceId,
    bool clearSelectedWorkplace = false,
    String? searchQuery,
    double? minRating,
    double? maxDistanceKm,
    String? selectedCity,
    double? searchRadiusKm,
    bool clearFilters = false,
  }) {
    return MapLoaded(
      workplaces: workplaces ?? this.workplaces,
      userLocation: userLocation ?? this.userLocation,
      selectedWorkplaceId: clearSelectedWorkplace
          ? null
          : (selectedWorkplaceId ?? this.selectedWorkplaceId),
      searchQuery: clearFilters ? '' : (searchQuery ?? this.searchQuery),
      minRating: clearFilters ? null : (minRating ?? this.minRating),
      maxDistanceKm: clearFilters ? null : (maxDistanceKm ?? this.maxDistanceKm),
      selectedCity: clearFilters ? null : (selectedCity ?? this.selectedCity),
      searchRadiusKm: searchRadiusKm ?? this.searchRadiusKm,
    );
  }

}

class MapError extends MapState {
  final String message;

  const MapError(this.message);

  @override
  List<Object?> get props => [message];
}

