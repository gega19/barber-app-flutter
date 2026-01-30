import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/map_constants.dart';
import '../common/app_card.dart';

/// Widget para mostrar la tarjeta de ubicación del barbero.
/// Si se proporcionan [latitude] y [longitude], muestra un min mapa y opción "Abrir en Maps".
class BarberLocationCardWidget extends StatelessWidget {
  final String location;
  final double? latitude;
  final double? longitude;

  const BarberLocationCardWidget({
    super.key,
    required this.location,
    this.latitude,
    this.longitude,
  });

  static const double _mapHeight = 140.0;
  static const double _miniMapZoom = 14.0;

  Future<void> _openInMaps(BuildContext context, double lat, double lng) async {
    // geo:lat,lng works on Android and iOS for default maps app
    final uri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      final fallback = Uri.parse('https://www.google.com/maps?q=$lat,$lng');
      if (await canLaunchUrl(fallback)) {
        await launchUrl(fallback, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCoordinates =
        latitude != null &&
        longitude != null &&
        latitude!.isFinite &&
        longitude!.isFinite;

    return RepaintBoundary(
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on,
                  color: AppColors.primaryGold,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ubicación',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (hasCoordinates) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: _mapHeight,
                  width: double.infinity,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(latitude!, longitude!),
                      initialZoom: _miniMapZoom,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: MapConstants.tileUrlTemplate,
                        userAgentPackageName: MapConstants.userAgentPackageName,
                        maxZoom: MapConstants.tileMaxZoom.toDouble(),
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(latitude!, longitude!),
                            width: 32,
                            height: 32,
                            child: const Icon(
                              Icons.location_on,
                              color: AppColors.primaryGold,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => _openInMaps(context, latitude!, longitude!),
                  icon: const Icon(
                    Icons.map_outlined,
                    size: 18,
                    color: AppColors.primaryGold,
                  ),
                  label: const Text(
                    'Abrir en Maps',
                    style: TextStyle(
                      color: AppColors.primaryGold,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
