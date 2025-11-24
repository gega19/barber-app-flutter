import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/injection/injection.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'core/services/socket_service.dart';
import 'core/services/analytics_service.dart';
import 'core/services/version_check_service.dart';
import 'presentation/cubit/auth/auth_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar orientación vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Inicializar Firebase
  try {
    await Firebase.initializeApp();
    // Inicializar servicio de notificaciones
    await NotificationService().initialize();
  } catch (e) {
    print('Error initializing Firebase: $e');
    // Continuar aunque Firebase falle (para desarrollo sin Firebase configurado)
  }

  // Inicializar inyección de dependencias
  await init();

  // Inicializar servicio de analytics
  try {
    await sl<AnalyticsService>().initialize();
    // Track app opened
    await sl<AnalyticsService>().trackEvent(
      eventName: 'app_opened',
      eventType: 'system_event',
    );
  } catch (e) {
    print('Error initializing Analytics: $e');
    // Continuar aunque analytics falle
  }

  // Inicializar servicio de verificación de versión
  try {
    final versionCheckService = sl<VersionCheckService>();
    await versionCheckService.initialize();

    debugPrint('🔍 Checking app version on startup...');
    final versionCheckResult = await versionCheckService.checkVersion();

    debugPrint('📊 Version check result: $versionCheckResult');

    if (versionCheckResult == VersionCheckResult.updateAvailable) {
      debugPrint('📢 Update available (not forced)');
      // Aquí podrías mostrar un diálogo opcional para actualizar
    } else if (versionCheckResult == VersionCheckResult.upToDate) {
      debugPrint('✅ App is up to date');
    } else {
      debugPrint('⚠️ Error checking version, continuing anyway');
    }
  } catch (e) {
    debugPrint('❌ Error initializing version check: $e');
    // Continuar aunque la verificación de versión falle
  }

  // Inicializar formato de fechas para español
  await initializeDateFormatting('es_ES', null);

  // Configurar conexión/desconexión automática de Socket.IO basada en autenticación
  _setupSocketConnection();

  runApp(const BarberApp());
}

/// Configura la conexión/desconexión automática del socket basada en el estado de autenticación
void _setupSocketConnection() {
  final authCubit = sl<AuthCubit>();
  final socketService = sl<SocketService>();

  authCubit.stream.listen((authState) {
    if (authState is AuthAuthenticated) {
      // Conectar socket cuando el usuario se autentica
      socketService.connect().catchError((error) {
        print('⚠️ Error connecting socket after authentication: $error');
      });
    } else if (authState is AuthInitial || authState is AuthError) {
      // Desconectar socket cuando el usuario se desautentica
      socketService.disconnect();
    }
  });
}

class BarberApp extends StatelessWidget {
  const BarberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<AuthCubit>(),
      child: MaterialApp.router(
        title: 'bartop',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
