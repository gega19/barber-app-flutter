import 'package:flutter/material.dart';
import 'main.dart' as entry_point;
import 'config/environment.dart';

/// Dev entry point. API base URL:
/// - Emulador Android: 10.0.2.2 (por defecto)
/// - Dispositivo físico: pasa la IP de tu PC/Mac en la red local.
///   Ejemplo: flutter run -t lib/main_dev.dart --dart-define=DEV_API_HOST=192.168.1.100
///   O usa el script: ./scripts/run_dev_device.sh
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 10.0.2.2 = localhost del host en emulador Android. En dispositivo físico usa DEV_API_HOST.
  const devHost = String.fromEnvironment(
    'DEV_API_HOST',
    defaultValue: '10.0.2.2', //'192.168.1.100''10.0.2.2',
  );
  const devPort = String.fromEnvironment('DEV_API_PORT', defaultValue: '3000');
  final apiBaseUrl = 'http://$devHost:$devPort';

  Environment.init(
    AppConfig(
      environment: EnvironmentType.dev,
      apiBaseUrl: apiBaseUrl,
      enableAnalytics: false,
    ),
  );

  entry_point.main();
}
