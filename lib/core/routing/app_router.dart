import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/main/main_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/barber/barber_detail_screen.dart';
import '../../presentation/screens/barber/barber_all_courses_screen.dart';
import '../../presentation/screens/workplace/workplace_detail_screen.dart';
import '../../presentation/screens/list/barbers_list_screen.dart';
import '../../presentation/screens/list/workplaces_list_screen.dart';
import '../../presentation/screens/list/promotions_list_screen.dart';
import '../../presentation/screens/profile/become_barber_screen.dart';
import '../../presentation/screens/profile/barber_services_screen.dart';
import '../../presentation/screens/profile/barber_media_screen.dart';
import '../../presentation/screens/profile/barber_info_screen.dart';
import '../../presentation/screens/profile/barber_availability_screen.dart';
import '../../presentation/screens/profile/barber_courses_screen.dart';
import '../../presentation/screens/profile/security_settings_screen.dart';
import '../../presentation/screens/booking/booking_screen.dart';
import '../../presentation/screens/appointment/appointment_detail_screen.dart';
import '../../presentation/screens/force_update/force_update_screen.dart';
import '../../core/injection/injection.dart';
import '../../data/datasources/local/local_storage.dart';
import '../../presentation/cubit/auth/auth_cubit.dart';
import '../../core/services/version_check_service.dart';
import '../../presentation/cubit/barber/barber_cubit.dart';
import '../../presentation/cubit/workplace/workplace_cubit.dart';
import '../../presentation/cubit/review/review_cubit.dart';
import '../../presentation/cubit/payment_method/payment_method_cubit.dart';
import '../../presentation/cubit/barber_availability/barber_availability_cubit.dart';
import '../../presentation/cubit/appointment/appointment_cubit.dart';
import '../../presentation/cubit/barber_course/barber_course_cubit.dart';
import '../../presentation/cubit/promotion/promotion_cubit.dart';
import '../../../core/constants/app_colors.dart';
import '../../core/services/analytics_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

/// Listenable wrapper para el stream del AuthCubit
class AuthStreamNotifier extends ChangeNotifier {
  final AuthCubit authCubit;
  StreamSubscription? _subscription;

  AuthStreamNotifier(this.authCubit) {
    _subscription = authCubit.stream.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Observer para trackear cambios de ruta
class AnalyticsRouteObserver extends NavigatorObserver {
  final AnalyticsService analyticsService;

  AnalyticsRouteObserver(this.analyticsService);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _trackRoute(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _trackRoute(newRoute);
    }
  }

  void _trackRoute(Route<dynamic> route) {
    final routeName = route.settings.name;
    if (routeName != null) {
      analyticsService.trackScreenView(routeName);
    }
  }
}

/// Función auxiliar para cargar la información de versión
Future<Map<String, dynamic>> _loadVersionInfo() async {
  final versionCheckService = sl<VersionCheckService>();
  
  // Asegurarse de que el servicio esté inicializado
  if (versionCheckService.getCurrentVersionInfo() == null) {
    await versionCheckService.initialize();
  }
  
  final currentVersionInfo = versionCheckService.getCurrentVersionInfo();
  final minimumVersionInfo = await versionCheckService.getMinimumVersionInfo();
  
  // Si no hay información, intentar obtenerla nuevamente
  if (currentVersionInfo == null || minimumVersionInfo == null) {
    debugPrint('⚠️ Version info not available, fetching...');
    await versionCheckService.checkVersion();
    final minInfo = await versionCheckService.getMinimumVersionInfo();
    final currentInfo = versionCheckService.getCurrentVersionInfo();
    
    return {
      'currentVersionInfo': currentInfo,
      'minimumVersionInfo': minInfo,
    };
  }
  
  return {
    'currentVersionInfo': currentVersionInfo,
    'minimumVersionInfo': minimumVersionInfo,
  };
}

GoRouter createAppRouter() {
  final authCubit = sl<AuthCubit>();
  final authNotifier = AuthStreamNotifier(authCubit);
  final localStorage = sl<LocalStorage>();
  final analyticsService = sl<AnalyticsService>();
  
  return GoRouter(
    initialLocation: '/login',
    observers: [AnalyticsRouteObserver(analyticsService)],
    redirect: (context, state) async {
      final isForceUpdate = state.matchedLocation == '/force-update';
      
      // Si está en la pantalla de force-update, no redirigir
      if (isForceUpdate) {
        return null;
      }
      
      // Verificar versión antes de cualquier otra redirección
      try {
        final versionCheckService = sl<VersionCheckService>();
        final versionCheckResult = await versionCheckService.checkVersion();
        final minimumVersionInfo = await versionCheckService.getMinimumVersionInfo();
        final currentVersionInfo = versionCheckService.getCurrentVersionInfo();
        
        if (versionCheckResult == VersionCheckResult.updateRequired && 
            minimumVersionInfo != null && 
            currentVersionInfo != null) {
          // Redirigir a la pantalla de actualización forzada
          return '/force-update';
        }
      } catch (e) {
        debugPrint('⚠️ Error checking version in redirect: $e');
        // Continuar con el flujo normal si hay error
      }
      
      final authState = authCubit.state;
      final isOnboarding = state.matchedLocation == '/onboarding';
      final isLoggingIn = state.matchedLocation == '/login';
      
      final isAuthenticated = authState is AuthAuthenticated || authState is AuthProfileUpdateError;
      final isLoading = authState is AuthLoading;
      
      // Verificar si el onboarding ya se completó
      final onboardingCompleted = await localStorage.isOnboardingCompleted();
      
      // Si viene con parámetro return, permitir ver el onboarding aunque esté completado
      final hasReturnParam = state.uri.queryParameters.containsKey('return');
      
      // Si no ha completado el onboarding y no está en la pantalla de onboarding, redirigir
      if (!onboardingCompleted && !isOnboarding && !isLoading) {
        return '/onboarding';
      }
      
      // Si ya completó el onboarding y está en la pantalla de onboarding (sin return param), redirigir
      // Pero si tiene return param, permitir verlo (viene del perfil)
      if (onboardingCompleted && isOnboarding && !hasReturnParam) {
        // Si está autenticado, ir a home, si no, a login
        return isAuthenticated ? '/home' : '/login';
      }
      
      if (isAuthenticated && isLoggingIn) {
        return '/home';
      }
      
      if (!isAuthenticated && !isLoading && !isLoggingIn && onboardingCompleted) {
        return '/login';
      }
      
      return null;
    },
    refreshListenable: authNotifier,
    routes: [
      GoRoute(
        path: '/force-update',
        builder: (context, state) {
          return FutureBuilder<Map<String, dynamic>>(
            future: _loadVersionInfo(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  backgroundColor: AppColors.backgroundDark,
                  body: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGold,
                    ),
                  ),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return Scaffold(
                  backgroundColor: AppColors.backgroundDark,
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Error al verificar la versión',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                          ),
                        ),
                        if (snapshot.hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${snapshot.error}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }

              final data = snapshot.data!;
              final currentVersionInfo = data['currentVersionInfo'] as AppVersionInfo?;
              final minimumVersionInfo = data['minimumVersionInfo'] as MinimumVersionResponse?;

              if (currentVersionInfo == null || minimumVersionInfo == null) {
                return Scaffold(
                  backgroundColor: AppColors.backgroundDark,
                  body: const Center(
                    child: Text(
                      'Información de versión no disponible',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                      ),
                    ),
                  ),
                );
              }

              return ForceUpdateScreen(
                minimumVersionInfo: minimumVersionInfo,
                currentVersionInfo: currentVersionInfo,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) {
          final returnRoute = state.uri.queryParameters['return'];
          return OnboardingScreen(returnRoute: returnRoute);
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => BlocProvider.value(
          value: authCubit,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: '/barber/:id',
        builder: (context, state) {
          final barberId = state.pathParameters['id']!;
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => sl<BarberCubit>()..loadBarbers(),
              ),
              BlocProvider(
                create: (_) => sl<ReviewCubit>(),
              ),
            ],
            child: BarberDetailScreen(barberId: barberId),
          );
        },
      ),
      GoRoute(
        path: '/booking/:id',
        builder: (context, state) {
          final barberId = state.pathParameters['id']!;
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => sl<BarberCubit>()..loadBarbers(),
              ),
              BlocProvider(
                create: (_) => sl<PaymentMethodCubit>(),
              ),
              BlocProvider(
                create: (_) => sl<AppointmentCubit>(),
              ),
            ],
            child: Builder(
              builder: (context) {
                final barberCubit = context.watch<BarberCubit>();
                if (barberCubit.state is BarberLoaded) {
                  final barbers = (barberCubit.state as BarberLoaded).barbers;
                  try {
                    final barber = barbers.firstWhere((b) => b.id == barberId);
                    return BookingScreen(barber: barber);
                  } catch (e) {
                    return Scaffold(
                      body: Center(
                        child: Text('Barbero no encontrado'),
                      ),
                    );
                  }
                }
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
          );
        },
      ),
      GoRoute(
        path: '/appointment/:id',
        builder: (context, state) {
          final appointmentId = state.pathParameters['id']!;
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: authCubit),
              BlocProvider(
                create: (_) => sl<AppointmentCubit>(),
              ),
            ],
            child: BlocBuilder<AppointmentCubit, AppointmentState>(
              builder: (context, appointmentState) {
                if (appointmentState is AppointmentLoaded) {
                  try {
                    final appointment = appointmentState.appointments.firstWhere(
                      (a) => a.id == appointmentId,
                    );
                    return AppointmentDetailScreen(appointment: appointment);
                  } catch (e) {
                    // Si no se encuentra la cita, intentar cargarla
                    // Por ahora, mostrar un error
                    return Scaffold(
                      body: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Cita no encontrada',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context.pop(),
                              child: const Text('Volver'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                }
                // Si no hay citas cargadas, cargar primero
                if (appointmentState is AppointmentInitial ||
                    appointmentState is AppointmentError) {
                  context.read<AppointmentCubit>().loadAppointments();
                }
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
          );
        },
      ),
      GoRoute(
        path: '/workplace/:id',
        builder: (context, state) {
          final workplaceId = state.pathParameters['id']!;
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => sl<WorkplaceCubit>(),
              ),
              BlocProvider(
                create: (_) => sl<BarberCubit>()..loadBarbers(),
              ),
              BlocProvider(
                create: (_) => sl<ReviewCubit>(),
              ),
            ],
            child: WorkplaceDetailScreen(workplaceId: workplaceId),
          );
        },
      ),
      GoRoute(
        path: '/become-barber',
        builder: (context, state) => BlocProvider.value(
          value: authCubit,
          child: const BecomeBarberScreen(),
        ),
      ),
      GoRoute(
        path: '/barber-services',
        builder: (context, state) => BlocProvider.value(
          value: authCubit,
          child: const BarberServicesScreen(),
        ),
      ),
                    GoRoute(
                path: '/barber-media',
                builder: (context, state) => BlocProvider.value(
                  value: authCubit,
                  child: const BarberMediaScreen(),
                ),
              ),
              GoRoute(
                path: '/barber-info',
                builder: (context, state) => BlocProvider.value(
                  value: authCubit,
                  child: const BarberInfoScreen(),
                ),
              ),
              GoRoute(
                path: '/barber-availability',
                builder: (context, state) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: authCubit),
                    BlocProvider(
                      create: (_) => sl<BarberAvailabilityCubit>(),
                    ),
                  ],
                  child: const BarberAvailabilityScreen(),
                ),
              ),
      GoRoute(
        path: '/barber-courses',
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: authCubit),
            BlocProvider(
              create: (_) => sl<BarberCourseCubit>(),
            ),
          ],
          child: const BarberCoursesScreen(),
        ),
      ),
      GoRoute(
        path: '/barber-courses-all',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          final barberId = args?['barberId'] as String? ?? 
                          state.pathParameters['barberId'] ?? 
                          state.uri.queryParameters['barberId'] ?? '';
          final barberName = args?['barberName'] as String?;
          return BarberAllCoursesScreen(
            barberId: barberId,
            barberName: barberName,
          );
        },
      ),
              GoRoute(
                path: '/security-settings',
                builder: (context, state) => BlocProvider.value(
                  value: authCubit,
                  child: const SecuritySettingsScreen(),
                ),
              ),
      GoRoute(
        path: '/barbers',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<BarberCubit>(),
          child: const BarbersListScreen(),
        ),
      ),
      GoRoute(
        path: '/workplaces',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<WorkplaceCubit>(),
          child: const WorkplacesListScreen(),
        ),
      ),
      GoRoute(
        path: '/promotions',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<PromotionCubit>(),
          child: const PromotionsListScreen(),
        ),
      ),
    ],
  );
}

final appRouter = createAppRouter();
