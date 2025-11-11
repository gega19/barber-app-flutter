class AppConstants {
  AppConstants._();

  static String get baseUrl {
    // Desarrollo local
    // return 'http://10.0.2.2:3000';  // Android Emulator
    // return 'http://localhost:3000';  // iOS Simulator o Web
    return 'http://192.168.7.140:3000';  // Physical device (IP local actual)
    // return 'http://10.225.1.16:3000';  // IP alternativa si la anterior no funciona
    
    // Producción - Render (descomentar para producción)
    // return 'https://barber-app-backend-kj6s.onrender.com';
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
}


