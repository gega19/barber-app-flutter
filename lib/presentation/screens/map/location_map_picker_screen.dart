import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/map_constants.dart';
import '../../../core/injection/injection.dart';
import '../../../core/services/location_service.dart';
import '../../utils/location_error_dialog.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

/// Resultado al confirmar la selección de ubicación en el mapa
class LocationPickerResult {
  final double latitude;
  final double longitude;
  final String address;

  const LocationPickerResult({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}

/// Pantalla para elegir una ubicación en el mapa (tap) o usar la actual.
class LocationMapPickerScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final String initialAddress;

  const LocationMapPickerScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialAddress = '',
  });

  @override
  State<LocationMapPickerScreen> createState() =>
      _LocationMapPickerScreenState();
}

class _LocationMapPickerScreenState extends State<LocationMapPickerScreen> {
  final MapController _mapController = MapController();
  final LocationService _locationService = sl<LocationService>();
  final TextEditingController _addressController = TextEditingController();

  double? _latitude;
  double? _longitude;
  bool _loadingMyLocation = false;
  static const double _pickerZoom = 15.0;

  @override
  void initState() {
    super.initState();
    _latitude = widget.initialLatitude;
    _longitude = widget.initialLongitude;
    _addressController.text = widget.initialAddress;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _centerMapOnSelection(),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _centerMapOnSelection() {
    final lat = _latitude ?? MapConstants.defaultLatitude;
    final lng = _longitude ?? MapConstants.defaultLongitude;
    _mapController.move(LatLng(lat, lng), _pickerZoom);
  }

  Future<void> _useMyLocation() async {
    setState(() {
      _loadingMyLocation = true;
    });
    final result = await _locationService.getCurrentLocationWithResult();
    if (!mounted) return;
    setState(() {
      _loadingMyLocation = false;
    });
    if (result.isSuccess) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
        if (_addressController.text.trim().isEmpty) {
          _addressController.text = 'Mi ubicación';
        }
      });
      _mapController.move(
        LatLng(result.latitude!, result.longitude!),
        _pickerZoom,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ubicación actual establecida. Ajusta el pin si quieres.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      showLocationErrorDialog(context, result.error!);
    }
  }

  void _onConfirm() {
    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Toca el mapa para marcar tu ubicación o usa "Mi ubicación actual".',
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Escribe una descripción de la ubicación (ej: ciudad, dirección).',
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    Navigator.of(context).pop(
      LocationPickerResult(
        latitude: _latitude!,
        longitude: _longitude!,
        address: address,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final centerLat = _latitude ?? MapConstants.defaultLatitude;
    final centerLng = _longitude ?? MapConstants.defaultLongitude;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Elegir ubicación',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(centerLat, centerLng),
                    initialZoom: _pickerZoom,
                    minZoom: MapConstants.minZoom,
                    maxZoom: MapConstants.maxZoom,
                    onTap: (_, point) {
                      setState(() {
                        _latitude = point.latitude;
                        _longitude = point.longitude;
                      });
                    },
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: MapConstants.tileUrlTemplate,
                      userAgentPackageName: MapConstants.userAgentPackageName,
                      maxZoom: MapConstants.tileMaxZoom.toDouble(),
                    ),
                    if (_latitude != null && _longitude != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(_latitude!, _longitude!),
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_on,
                              color: AppColors.primaryGold,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton(
                    heroTag: 'my_location_picker',
                    onPressed: _loadingMyLocation ? null : _useMyLocation,
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: AppColors.textDark,
                    child: _loadingMyLocation
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textDark,
                            ),
                          )
                        : const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.backgroundCard,
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Toca el mapa para colocar el pin o usa "Mi ubicación actual".',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _addressController,
                    label: 'Descripción de la ubicación',
                    hint: 'Ej: Caracas, Distrito Capital o dirección',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.primaryGold,
                            ),
                            foregroundColor: AppColors.primaryGold,
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: AppButton(
                          text: 'Usar esta ubicación',
                          onPressed: _onConfirm,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
