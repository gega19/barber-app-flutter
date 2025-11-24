class AppConstants {
  AppConstants._();

  static String get baseUrl {
    // Producción - Railway
    return 'https://bartop-p.up.railway.app';

    // Desarrollo local - Detecta automáticamente la plataforma
    // if (kIsWeb) {
    //   // Web usa localhost
    //   return 'http://localhost:3000';
    // } else if (Platform.isAndroid) {
    //   return 'http://192.168.7.140:3000';
    // } else if (Platform.isIOS) {
    //   // iOS Simulator puede usar localhost directamente
    //   return 'http://localhost:3000';
    // } else {
    //   // Otras plataformas (Linux, Windows, macOS)
    //   return 'http://localhost:3000';
    // }
  }

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String rememberMeKey = 'remember_me';
  static const String savedEmailKey = 'saved_email';
  static const String biometricEnabledKey = 'biometric_enabled';

  // App Info
  static const String appName = 'bartop';
  static const String appTagline = 'Encuentra a tu barbero ideal';

  // Landing Page URL
  static const String landingUrl = 'https://bartopve.vercel.app';

  // Analytics Configuration
  /// Si es true, permite enviar eventos de analytics en modo desarrollo
  /// Por defecto es false (no se envían eventos en dev)
  static const bool enableAnalyticsInDev = false;

  /// Construye una URL completa a partir de una URL relativa o absoluta
  /// Si la URL ya es absoluta (empieza con http), la devuelve tal cual
  /// Si es relativa, la concatena con baseUrl
  static String buildImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return '';
    }

    // Si ya es una URL absoluta, devolverla tal cual
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    // Si es relativa, construir la URL completa
    // Asegurarse de que la URL relativa empiece con /
    final relativeUrl = url.startsWith('/') ? url : '/$url';
    return '$baseUrl$relativeUrl';
  }
}
