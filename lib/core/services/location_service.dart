import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/logger.dart';

/// Resultado detallado al obtener la ubicación actual (para mensajes al usuario)
enum LocationErrorReason {
  serviceDisabled,
  permissionDenied,
  permissionPermanentlyDenied,
  timeout,
  unknown,
}

/// Resultado de getCurrentLocationWithResult
class LocationResult {
  final double? latitude;
  final double? longitude;
  final LocationErrorReason? error;

  const LocationResult._({this.latitude, this.longitude, this.error});

  factory LocationResult.success(double lat, double lng) =>
      LocationResult._(latitude: lat, longitude: lng);

  factory LocationResult.failure(LocationErrorReason reason) =>
      LocationResult._(error: reason);

  bool get isSuccess => latitude != null && longitude != null;
}

/// Servicio para manejar la ubicación del usuario
class LocationService {
  /// Verifica si los permisos de ubicación están concedidos
  Future<bool> hasLocationPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  /// Solicita permisos de ubicación
  Future<bool> requestLocationPermission() async {
    try {
      final status = await Permission.location.request();
      return status.isGranted;
    } catch (e) {
      appLogger.e('Error requesting location permission: $e');
      return false;
    }
  }

  /// Verifica si los servicios de ubicación están habilitados
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      appLogger.e('Error checking location service: $e');
      return false;
    }
  }

  /// Obtiene la ubicación actual del usuario
  /// Retorna null si no se puede obtener la ubicación
  Future<Position?> getCurrentLocation() async {
    final result = await getCurrentLocationWithResult();
    if (result.isSuccess) {
      return Position(
        latitude: result.latitude!,
        longitude: result.longitude!,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    }
    return null;
  }

  /// Obtiene la ubicación actual con resultado detallado para mostrar errores al usuario
  Future<LocationResult> getCurrentLocationWithResult() async {
    try {
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        appLogger.w('Location services are disabled');
        return LocationResult.failure(LocationErrorReason.serviceDisabled);
      }

      bool hasPermission = await hasLocationPermission();
      if (!hasPermission) {
        final status = await Permission.location.request();
        if (status.isGranted) {
          hasPermission = true;
        } else if (status.isPermanentlyDenied) {
          appLogger.w('Location permission permanently denied');
          return LocationResult.failure(
            LocationErrorReason.permissionPermanentlyDenied,
          );
        } else {
          appLogger.w('Location permission denied');
          return LocationResult.failure(LocationErrorReason.permissionDenied);
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return LocationResult.success(position.latitude, position.longitude);
    } on TimeoutException {
      appLogger.w('Location request timed out');
      return LocationResult.failure(LocationErrorReason.timeout);
    } catch (e) {
      appLogger.e('Error getting current location: $e');
      return LocationResult.failure(LocationErrorReason.unknown);
    }
  }

  /// Obtiene la última ubicación conocida (más rápido, puede ser menos precisa)
  Future<Position?> getLastKnownLocation() async {
    try {
      final hasPermission = await hasLocationPermission();
      if (!hasPermission) {
        return null;
      }

      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      appLogger.e('Error getting last known location: $e');
      return null;
    }
  }

  /// Calcula la distancia entre dos puntos en kilómetros
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
          startLatitude,
          startLongitude,
          endLatitude,
          endLongitude,
        ) /
        1000; // Convertir de metros a kilómetros
  }

  /// Formatea la distancia en un string legible
  String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).round()} m';
    } else if (distanceInKm < 10) {
      return '${distanceInKm.toStringAsFixed(1)} km';
    } else {
      return '${distanceInKm.round()} km';
    }
  }
}
