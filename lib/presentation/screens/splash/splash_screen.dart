import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/injection/injection.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/version_check_service.dart';
import '../../../data/datasources/local/local_storage.dart';
import '../../cubit/auth/auth_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final authCubit = sl<AuthCubit>();
      final localStorage = sl<LocalStorage>();
      final versionCheckService = sl<VersionCheckService>();

      // Inicializar formato de fechas para español
      await initializeDateFormatting('es_ES', null);

      // Inicializar servicio de analytics
      try {
        await sl<AnalyticsService>().initialize();
        // Track app opened
        await sl<AnalyticsService>().trackEvent(
          eventName: 'app_opened',
          eventType: 'system_event',
        );
      } catch (e) {
        debugPrint('Error initializing Analytics: $e');
        // Continuar aunque analytics falle
      }

      // Inicializar AuthCubit para verificar si hay usuario guardado
      await authCubit.init();

      // Esperar un poco para que el usuario vea el splash (mínimo 1 segundo)
      await Future.delayed(const Duration(milliseconds: 1000));

      if (!mounted) return;

      // Verificar versión
      try {
        final versionCheckResult = await versionCheckService.checkVersion();
        final minimumVersionInfo = await versionCheckService
            .getMinimumVersionInfo();
        final currentVersionInfo = versionCheckService.getCurrentVersionInfo();

        if (versionCheckResult == VersionCheckResult.updateRequired &&
            minimumVersionInfo != null &&
            currentVersionInfo != null) {
          if (mounted) {
            context.go('/force-update');
            return;
          }
        }
      } catch (e) {
        debugPrint('⚠️ Error checking version: $e');
        // Continuar con el flujo normal si hay error
      }

      if (!mounted) return;

      // Verificar onboarding
      final onboardingCompleted = await localStorage.isOnboardingCompleted();
      final authState = authCubit.state;
      final isAuthenticated =
          authState is AuthAuthenticated || authState is AuthProfileUpdateError;

      // Redirigir según el estado
      if (!onboardingCompleted) {
        if (mounted) {
          context.go('/onboarding');
        }
      } else if (isAuthenticated) {
        if (mounted) {
          context.go('/home');
        }
      } else {
        // Modo Invitado: Si no está autenticado pero completó el onboarding, ir a Home
        if (mounted) {
          context.go('/home');
        }
      }
    } catch (e) {
      debugPrint('❌ Error initializing app: $e');
      // En caso de error, preferimos ir a Home (Modo Invitado) en lugar de bloquear en Login
      if (mounted) {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGold.withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/logo.png',
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback si no se encuentra la imagen
                      return Container(
                        decoration: const BoxDecoration(
                          color: AppColors.primaryGold,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.content_cut,
                          size: 70,
                          color: AppColors.textDark,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Nombre de la app
              Text(
                AppConstants.appName,
                style: const TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              // Tagline
              Text(
                AppConstants.appTagline,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 48),
              // Loading indicator
              const CircularProgressIndicator(
                color: AppColors.primaryGold,
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
