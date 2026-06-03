enum EnvironmentType { dev, prod }

class AppConfig {
  final EnvironmentType environment;
  final String apiBaseUrl;
  final bool enableAnalytics;
  /// OAuth 2.0 Web Client ID (same as backend GOOGLE_CLIENT_ID).
  /// Pass via --dart-define=GOOGLE_WEB_CLIENT_ID=xxx
  final String googleWebClientId;

  AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    this.enableAnalytics = false,
    this.googleWebClientId = '',
  });
}

class Environment {
  static AppConfig? _config;

  static void init(AppConfig config) {
    _config = config;
  }

  static AppConfig get config {
    if (_config == null) {
      // Default fallback to Prod if not manually initialized (safety)
      return AppConfig(
        environment: EnvironmentType.prod,
        // apiBaseUrl: 'https://barber-api.corporacionceg.com',
        apiBaseUrl: 'http://10.16.1.159:3000',
        enableAnalytics: true,
      );
    }
    return _config!;
  }
}
