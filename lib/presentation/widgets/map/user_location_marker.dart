import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/map_constants.dart';

/// Widget para el marcador de ubicación del usuario
class UserLocationMarker extends StatelessWidget {
  final Position userLocation;

  const UserLocationMarker({
    super.key,
    required this.userLocation,
  });

  /// Construye el marcador para flutter_map
  static Marker buildMarker(Position position) {
    return Marker(
      point: LatLng(position.latitude, position.longitude),
      width: MapConstants.userMarkerSize.toDouble(),
      height: MapConstants.userMarkerSize.toDouble(),
      child: RepaintBoundary(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.info,
              width: 3,
            ),
          ),
          child: Icon(
            Icons.my_location,
            color: AppColors.info,
            size: MapConstants.userMarkerIconSize.toDouble(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.info,
          width: 3,
        ),
      ),
      child: Icon(
        Icons.my_location,
        color: AppColors.info,
        size: MapConstants.userMarkerIconSize.toDouble(),
      ),
    );
  }
}

