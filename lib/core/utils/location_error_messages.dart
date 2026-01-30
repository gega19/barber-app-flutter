import '../services/location_service.dart';

/// Mensajes y comportamiento de UI para cada tipo de error de ubicación.
/// Responsabilidad única: definir qué mostrar al usuario por cada [LocationErrorReason].
class LocationErrorMessages {
  LocationErrorMessages._();

  /// Mensaje legible para el usuario según el motivo del error.
  static String getUserMessage(LocationErrorReason reason) {
    switch (reason) {
      case LocationErrorReason.serviceDisabled:
        return 'El GPS está desactivado. Activa la ubicación en la configuración del dispositivo.';
      case LocationErrorReason.permissionDenied:
        return 'Se necesita permiso de ubicación para usar tu posición actual.';
      case LocationErrorReason.permissionPermanentlyDenied:
        return 'El permiso de ubicación fue denegado. Actívalo en la configuración de la app.';
      case LocationErrorReason.timeout:
        return 'Tardó demasiado en obtener la ubicación. Comprueba que el GPS esté activo e intenta de nuevo.';
      case LocationErrorReason.unknown:
        return 'No se pudo obtener la ubicación. Comprueba el GPS y los permisos e intenta de nuevo.';
    }
  }

  /// Indica si se debe mostrar el botón "Abrir configuración" para este error.
  static bool shouldOfferOpenSettings(LocationErrorReason reason) {
    switch (reason) {
      case LocationErrorReason.serviceDisabled:
      case LocationErrorReason.permissionPermanentlyDenied:
        return true;
      case LocationErrorReason.permissionDenied:
      case LocationErrorReason.timeout:
      case LocationErrorReason.unknown:
        return false;
    }
  }
}
