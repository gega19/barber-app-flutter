import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/environment.dart';
import 'core/injection/injection.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'core/services/socket_service.dart';
import 'presentation/cubit/auth/auth_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Default to Prod if not already initialized
  try {
    Environment.config;
  } catch (_) {
    Environment.init(
      AppConfig(
        environment: EnvironmentType.prod,
        apiBaseUrl: 'https://barber-api.corporacionceg.com',
        enableAnalytics: true,
        googleWebClientId: const String.fromEnvironment('GOOGLE_WEB_CLIENT_ID'),
      ),
    );
  }

  // Configurar orientación vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Inicializar Firebase
  try {
    await Firebase.initializeApp();
    await NotificationService().initializeWithoutPermissionRequest();
  } catch (e) {
    // Continuar aunque Firebase falle (para desarrollo sin Firebase configurado)
  }

  // Inicializar inyección de dependencias
  await init();

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
      socketService.connect().catchError((error) {});
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
