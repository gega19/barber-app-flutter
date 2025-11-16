/// Utilidades para trabajar con perfiles de usuario
class ProfileUtils {
  /// Formatea las estadísticas del usuario
  static String formatStatValue(dynamic value) {
    if (value is double) {
      return value.toStringAsFixed(1);
    } else if (value is int) {
      return value.toDouble().toStringAsFixed(1);
    }
    return value.toString();
  }

  /// Formatea el valor monetario
  static String formatCurrency(dynamic value) {
    final doubleValue = value is double
        ? value
        : (value is int ? value.toDouble() : 0.0);
    return r'$' + doubleValue.toStringAsFixed(0);
  }

  /// Verifica si un valor está configurado
  static bool isConfigured(String? value) {
    return value != null && value.isNotEmpty && value != 'No configurado';
  }

  /// Obtiene el valor a mostrar o un placeholder
  static String getDisplayValue(
    String? value, {
    String placeholder = 'No configurado',
  }) {
    return value != null && value.isNotEmpty ? value : placeholder;
  }
}
