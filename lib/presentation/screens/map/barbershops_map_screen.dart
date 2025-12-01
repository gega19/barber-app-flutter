import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/map_constants.dart';
import '../../../core/services/location_service.dart';
import '../../../domain/entities/workplace_entity.dart';
import '../../cubit/map/map_cubit.dart';
import '../../widgets/common/error_widget.dart' as error_widget;
import '../../widgets/common/loading_widget.dart';
import '../../widgets/map/workplace_marker.dart';
import '../../widgets/map/map_filters_widget.dart';
import '../../widgets/map/map_header_widget.dart';
import '../../widgets/map/map_loading_overlay.dart';
import '../../widgets/map/user_location_marker.dart';
import '../../../core/injection/injection.dart' as injection;

class BarbershopsMapScreen extends StatefulWidget {
  const BarbershopsMapScreen({super.key});

  @override
  State<BarbershopsMapScreen> createState() => _BarbershopsMapScreenState();
}

class _BarbershopsMapScreenState extends State<BarbershopsMapScreen> {
  final MapController _mapController = MapController();
  final LocationService _locationService = injection.sl<LocationService>();
  final TextEditingController _searchController = TextEditingController();
  double _currentZoom = MapConstants.initialZoom;
  bool _showFilters = false;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Cargar ubicación y barberías al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapCubit>().getUserLocation();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(MapConstants.searchDebounce, () {
      if (mounted) {
        context.read<MapCubit>().updateSearchQuery(_searchController.text);
      }
    });
  }

  void _centerOnUserLocation() {
    // Centrar el mapa en la ubicación del usuario usando el estado actual
    final currentState = context.read<MapCubit>().state;
    if (currentState is MapLoaded && currentState.userLocation != null) {
      final latLng = LatLng(
        currentState.userLocation!.latitude,
        currentState.userLocation!.longitude,
      );
      _mapController.move(latLng, _currentZoom);
    } else {
      // Si no hay ubicación en el estado, intentar obtenerla y centrar
      _locationService.getCurrentLocation().then((position) {
        if (position != null && mounted) {
          final latLng = LatLng(position.latitude, position.longitude);
          _mapController.move(latLng, _currentZoom);
        }
      });
    }
  }

  void _onMapMove(MapEvent event) {
    if (event is MapEventMove) {
      final newZoom = _mapController.camera.zoom;
      if (newZoom != _currentZoom) {
        setState(() {
          _currentZoom = newZoom;
        });
      }
    }
  }

  void _onWorkplaceTap(WorkplaceEntity workplace) {
    // Solo seleccionar la barbería para mostrar la tarjeta de información
    context.read<MapCubit>().selectWorkplace(workplace.id);
  }

  void _navigateToWorkplaceDetail(WorkplaceEntity workplace) {
    // Navegar a detalle de barbería
    context.push('/workplace/${workplace.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<MapCubit, MapState>(
            buildWhen: (previous, current) {
              // Reconstruir cuando cambia el tipo de estado o cuando cambian las barberías/filtros
              if (previous.runtimeType != current.runtimeType) return true;
              if (previous is MapLoaded && current is MapLoaded) {
                // Reconstruir si cambian las barberías, filtros o ubicación
                return previous.workplaces.length !=
                        current.workplaces.length ||
                    previous.searchQuery != current.searchQuery ||
                    previous.minRating != current.minRating ||
                    previous.selectedCity != current.selectedCity ||
                    previous.selectedWorkplaceId !=
                        current.selectedWorkplaceId ||
                    previous.userLocation != current.userLocation;
              }
              return false;
            },
            builder: (context, state) {
              if (state is MapLoading) {
                return const Center(child: LoadingWidget());
              }

              if (state is MapError) {
                return Center(
                  child: error_widget.AppErrorWidget(
                    message: state.message,
                    onRetry: () {
                      context.read<MapCubit>().getUserLocation();
                    },
                  ),
                );
              }

              if (state is MapLoaded) {
                final workplaces = state.filteredWorkplaces;
                final allWorkplaces = state.workplaces;
                final userLocation = state.userLocation;

                // Centro del mapa: usar ubicación del usuario si está disponible
                final center = userLocation != null
                    ? LatLng(userLocation.latitude, userLocation.longitude)
                    : const LatLng(
                        MapConstants.defaultLatitude,
                        MapConstants.defaultLongitude,
                      );

                final stackChildren = <Widget>[
                  // Mapa
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: center,
                      initialZoom: _currentZoom,
                      minZoom: MapConstants.minZoom,
                      maxZoom: MapConstants.maxZoom,
                      onMapEvent: _onMapMove,
                      onTap: (tapPosition, point) {
                        // Deseleccionar al tocar el mapa
                        final cubit = context.read<MapCubit>();
                        cubit.deselectWorkplace();
                      },
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all,
                      ),
                    ),
                    children: [
                      // Tiles de OpenStreetMap
                      TileLayer(
                        urlTemplate: MapConstants.tileUrlTemplate,
                        userAgentPackageName: MapConstants.userAgentPackageName,
                        maxZoom: MapConstants.tileMaxZoom.toDouble(),
                      ),
                      // Marcadores de barberías (solo las filtradas)
                      MarkerLayer(
                        markers: workplaces
                            .where(
                              (wp) =>
                                  wp.latitude != null && wp.longitude != null,
                            )
                            .map((workplace) {
                              final isSelected =
                                  state.selectedWorkplaceId == workplace.id;
                              return Marker(
                                point: LatLng(
                                  workplace.latitude!,
                                  workplace.longitude!,
                                ),
                                width: MapConstants.markerWidth.toDouble(),
                                height: MapConstants.markerHeight.toDouble(),
                                child: WorkplaceMarker(
                                  workplace: workplace,
                                  isSelected: isSelected,
                                  onTap: () => _onWorkplaceTap(workplace),
                                ),
                              );
                            })
                            .toList(),
                      ),
                      // Marcador de ubicación del usuario (siempre visible si hay ubicación)
                      if (userLocation != null)
                        MarkerLayer(
                          markers: [
                            UserLocationMarker.buildMarker(userLocation),
                          ],
                        ),
                    ],
                  ),
                  // Header con búsqueda
                  MapHeaderWidget(
                    searchQuery: state.searchQuery,
                    workplacesCount: workplaces.length,
                    hasActiveFilters:
                        state.searchQuery.isNotEmpty ||
                        state.minRating != null ||
                        state.selectedCity != null,
                    searchController: _searchController,
                    onFilterPressed: () {
                      setState(() {
                        _showFilters = !_showFilters;
                      });
                    },
                    onLocationPressed: _centerOnUserLocation,
                    onSearchChanged: (query) {
                      context.read<MapCubit>().updateSearchQuery(query);
                    },
                  ),
                ];

                // Agregar panel de filtros si está visible
                if (_showFilters) {
                  stackChildren.add(
                    Positioned(
                      top: 180,
                      left: 16,
                      right: 16,
                      child: Material(
                        color: Colors.transparent,
                        child: MapFiltersWidget(
                          selectedCity: state.selectedCity,
                          minRating: state.minRating,
                          availableCities: state.availableCities,
                          onCityChanged: (city) {
                            context.read<MapCubit>().filterByCity(city);
                          },
                          onMinRatingChanged: (rating) {
                            context.read<MapCubit>().filterByMinRating(rating);
                          },
                          onClearFilters: () {
                            _searchController.clear();
                            context.read<MapCubit>().clearFilters();
                          },
                          hasActiveFilters:
                              state.searchQuery.isNotEmpty ||
                              state.minRating != null ||
                              state.selectedCity != null,
                        ),
                      ),
                    ),
                  );
                }

                // Agregar info card si hay barbería seleccionada
                if (state.selectedWorkplaceId != null) {
                  stackChildren.add(
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Builder(
                        builder: (context) {
                          // Buscar la barbería seleccionada en la lista filtrada o en todas
                          final selected = workplaces.firstWhere(
                            (wp) => wp.id == state.selectedWorkplaceId,
                            orElse: () => allWorkplaces.firstWhere(
                              (wp) => wp.id == state.selectedWorkplaceId,
                            ),
                          );
                          double? distance;
                          if (userLocation != null &&
                              selected.latitude != null &&
                              selected.longitude != null) {
                            distance = _locationService.calculateDistance(
                              userLocation.latitude,
                              userLocation.longitude,
                              selected.latitude!,
                              selected.longitude!,
                            );
                          }
                          return WorkplaceInfoCard(
                            workplace: selected,
                            distance: distance,
                            onViewDetails: () =>
                                _navigateToWorkplaceDetail(selected),
                            onClose: () {
                              final cubit = context.read<MapCubit>();
                              cubit.deselectWorkplace();
                            },
                          );
                        },
                      ),
                    ),
                  );
                }

                // Agregar overlay de carga si es necesario
                if (allWorkplaces.isEmpty && userLocation != null) {
                  stackChildren.add(const MapLoadingOverlay());
                }

                return Stack(children: stackChildren);
              }

              // Estado inicial
              return const Center(child: LoadingWidget());
            },
          ),
        ),
      ),
    );
  }
}
