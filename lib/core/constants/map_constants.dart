/// Constantes para la funcionalidad del mapa
class MapConstants {
  MapConstants._();

  // Coordenadas por defecto (Caracas, Venezuela)
  static const double defaultLatitude = 10.4806;
  static const double defaultLongitude = -66.9036;

  // Configuración de zoom
  static const double initialZoom = 13.0;
  static const double minZoom = 10.0;
  static const double maxZoom = 18.0;

  // Tiempos y delays
  static const Duration searchDebounce = Duration(milliseconds: 500);

  // Tamaños de marcadores
  static const int markerWidth = 50;
  static const int markerHeight = 50;
  static const int userMarkerSize = 40;
  static const int userMarkerIconSize = 24;

  // Configuración de tiles
  static const String tileUrlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String userAgentPackageName = 'com.bartop.app';
  static const int tileMaxZoom = 19;
}

