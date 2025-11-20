import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/location_service.dart';
import '../../../domain/entities/workplace_entity.dart';
import '../../cubit/map/map_cubit.dart';
import '../../widgets/common/error_widget.dart' as error_widget;
import '../../widgets/common/loading_widget.dart';
import '../../widgets/map/workplace_marker.dart';
import '../../widgets/map/map_filters_widget.dart';
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
  LatLng? _userLocationLatLng;
  double _currentZoom = 13.0;
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
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<MapCubit>().updateSearchQuery(_searchController.text);
      }
    });
  }

  void _centerOnUserLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null && mounted) {
      final latLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _userLocationLatLng = latLng;
      });
      _mapController.move(latLng, _currentZoom);
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
            builder: (context, state) {
              if (state is MapLoading) {
                return const Center(
                  child: LoadingWidget(),
                );
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
                final workplaces = context.read<MapCubit>().getFilteredWorkplaces();
                final allWorkplaces = state.workplaces;
                final userLocation = state.userLocation;

                // Convertir Position a LatLng si existe
                if (userLocation != null && _userLocationLatLng == null) {
                  _userLocationLatLng = LatLng(
                    userLocation.latitude,
                    userLocation.longitude,
                  );
                }

                // Centro por defecto (Caracas, Venezuela) si no hay ubicación
                final center = _userLocationLatLng ??
                    const LatLng(10.4806, -66.9036);

                return Stack(
                  children: [
                    // Mapa
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: center,
                        initialZoom: _currentZoom,
                        minZoom: 10.0,
                        maxZoom: 18.0,
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
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.bartop.app',
                          maxZoom: 19,
                        ),
                        // Marcadores de barberías (solo las filtradas)
                        MarkerLayer(
                          markers: workplaces
                              .where((wp) =>
                                  wp.latitude != null &&
                                  wp.longitude != null)
                              .map((workplace) {
                            final isSelected =
                                state.selectedWorkplaceId == workplace.id;
                            return Marker(
                              point: LatLng(
                                workplace.latitude!,
                                workplace.longitude!,
                              ),
                              width: 50,
                              height: 50,
                              child: WorkplaceMarker(
                                workplace: workplace,
                                isSelected: isSelected,
                                onTap: () => _onWorkplaceTap(workplace),
                              ),
                            );
                          }).toList(),
                        ),
                        // Marcador de ubicación del usuario
                        if (_userLocationLatLng != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _userLocationLatLng!,
                                width: 40,
                                height: 40,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.info.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.info,
                                      width: 3,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.my_location,
                                    color: AppColors.info,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    // Header con búsqueda
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.backgroundDark.withValues(alpha: 0.95),
                              AppColors.backgroundDark.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Mapa de Barberías',
                                        style: TextStyle(
                                          color: AppColors.primaryGold,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${workplaces.length} barbería${workplaces.length != 1 ? 's' : ''} encontrada${workplaces.length != 1 ? 's' : ''}',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Botón de filtros
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundCard,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: (state.searchQuery.isNotEmpty ||
                                              state.minRating != null ||
                                              state.maxDistanceKm != null ||
                                              state.selectedCity != null)
                                          ? AppColors.primaryGold
                                          : AppColors.primaryGold.withValues(
                                              alpha: 0.3,
                                            ),
                                    ),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.filter_list,
                                      color: (state.searchQuery.isNotEmpty ||
                                              state.minRating != null ||
                                              state.maxDistanceKm != null ||
                                              state.selectedCity != null)
                                          ? AppColors.primaryGold
                                          : AppColors.textSecondary,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _showFilters = !_showFilters;
                                      });
                                    },
                                    tooltip: 'Filtros',
                                  ),
                                ),
                                // Botón para centrar en ubicación
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundCard,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primaryGold.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.my_location,
                                      color: AppColors.primaryGold,
                                    ),
                                    onPressed: _centerOnUserLocation,
                                    tooltip: 'Centrar en mi ubicación',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Barra de búsqueda
                            TextField(
                              controller: _searchController,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Buscar por nombre, dirección o ciudad...',
                                hintStyle: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: AppColors.textSecondary,
                                ),
                                suffixIcon: state.searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.clear,
                                          color: AppColors.textSecondary,
                                        ),
                                        onPressed: () {
                                          _searchController.clear();
                                          context.read<MapCubit>().updateSearchQuery('');
                                        },
                                      )
                                    : null,
                                filled: true,
                                fillColor: AppColors.backgroundCard,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.primaryGold.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.primaryGold.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.primaryGold,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Panel de filtros
                    if (_showFilters)
                      Positioned(
                        top: 180,
                        left: 16,
                        right: 16,
                        child: Material(
                          color: Colors.transparent,
                          child: MapFiltersWidget(
                            selectedCity: state.selectedCity,
                            minRating: state.minRating,
                            maxDistanceKm: state.maxDistanceKm,
                            searchRadiusKm: state.searchRadiusKm,
                            availableCities: context.read<MapCubit>().getAvailableCities(),
                            onCityChanged: (city) {
                              context.read<MapCubit>().filterByCity(city);
                            },
                            onMinRatingChanged: (rating) {
                              context.read<MapCubit>().filterByMinRating(rating);
                            },
                            onMaxDistanceChanged: (distance) {
                              context.read<MapCubit>().filterByMaxDistance(distance);
                            },
                            onRadiusChanged: (radius) {
                              context.read<MapCubit>().updateSearchRadius(radius);
                            },
                            onClearFilters: () {
                              _searchController.clear();
                              context.read<MapCubit>().clearFilters();
                            },
                            hasActiveFilters: state.searchQuery.isNotEmpty ||
                                state.minRating != null ||
                                state.maxDistanceKm != null ||
                                state.selectedCity != null,
                          ),
                        ),
                      ),
                    // Info card de barbería seleccionada (si hay)
                    if (state.selectedWorkplaceId != null)
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
                              onViewDetails: () => _navigateToWorkplaceDetail(selected),
                              onClose: () {
                                final cubit = context.read<MapCubit>();
                                cubit.deselectWorkplace();
                              },
                            );
                          },
                        ),
                      ),
                  ],
                );
              }

              // Estado inicial
              return const Center(
                child: LoadingWidget(),
              );
            },
          ),
        ),
      ),
    );
  }
}

