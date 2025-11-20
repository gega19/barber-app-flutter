import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/logger.dart';

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
    try {
      // Verificar si los servicios de ubicación están habilitados
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        appLogger.w('Location services are disabled');
        return null;
      }

      // Verificar permisos
      bool hasPermission = await hasLocationPermission();
      if (!hasPermission) {
        // Intentar solicitar permisos
        hasPermission = await requestLocationPermission();
        if (!hasPermission) {
          appLogger.w('Location permission denied');
          return null;
        }
      }

      // Obtener ubicación
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return position;
    } on TimeoutException {
      appLogger.w('Location request timed out');
      return null;
    } catch (e) {
      appLogger.e('Error getting current location: $e');
      return null;
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
    ) / 1000; // Convertir de metros a kilómetros
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

