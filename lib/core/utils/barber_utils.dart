import 'package:intl/intl.dart';

/// Utilidades para operaciones relacionadas con barberos
class BarberUtils {
  // Formateador de fecha estático para evitar recrearlo
  static final DateFormat _dateFormat = DateFormat('d MMM yyyy', 'es_ES');

  /// Formatea una fecha para mostrar en la UI
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Obtiene el texto del tipo de servicio
  static String getServiceTypeLabel(String? serviceType) {
    if (serviceType == null) return '';
    
    switch (serviceType) {
      case 'LOCAL_ONLY':
        return 'Solo en local';
      case 'HOME_SERVICE':
        return 'Servicio a domicilio';
      case 'BOTH':
        return 'Ambos';
      default:
        return serviceType;
    }
  }

  /// Valida si un barbero es "Top" basado en su rating
  static bool isTopBarber(double rating) {
    return rating >= 4.8;
  }
}

