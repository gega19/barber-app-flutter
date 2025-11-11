import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/main/main_screen.dart';
import '../../presentation/screens/barber/barber_detail_screen.dart';
import '../../presentation/screens/workplace/workplace_detail_screen.dart';
import '../../presentation/screens/profile/become_barber_screen.dart';
import '../../presentation/screens/profile/barber_services_screen.dart';
import '../../presentation/screens/profile/barber_media_screen.dart';
import '../../presentation/screens/profile/barber_info_screen.dart';
import '../../presentation/screens/profile/barber_availability_screen.dart';
import '../../presentation/screens/profile/security_settings_screen.dart';
import '../../presentation/screens/booking/booking_screen.dart';
import '../../presentation/screens/appointment/appointment_detail_screen.dart';
import '../../core/injection/injection.dart';
import '../../presentation/cubit/auth/auth_cubit.dart';
import '../../presentation/cubit/barber/barber_cubit.dart';
import '../../presentation/cubit/workplace/workplace_cubit.dart';
import '../../presentation/cubit/review/review_cubit.dart';
import '../../presentation/cubit/payment_method/payment_method_cubit.dart';
import '../../presentation/cubit/barber_availability/barber_availability_cubit.dart';
import '../../presentation/cubit/appointment/appointment_cubit.dart';
import '../../../core/constants/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

GoRouter createAppRouter() {
  final authCubit = sl<AuthCubit>();
  final authNotifier = AuthStreamNotifier(authCubit);
  
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final authState = authCubit.state;
      final isLoggingIn = state.matchedLocation == '/login';
      
      final isAuthenticated = authState is AuthAuthenticated || authState is AuthProfileUpdateError;
      final isLoading = authState is AuthLoading;
      
      if (isAuthenticated && isLoggingIn) {
        return '/home';
      }
      
      if (!isAuthenticated && !isLoading && !isLoggingIn) {
        return '/login';
      }
      
      return null;
    },
    refreshListenable: authNotifier,
    routes: [
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
                path: '/security-settings',
                builder: (context, state) => BlocProvider.value(
                  value: authCubit,
                  child: const SecuritySettingsScreen(),
                ),
              ),
    ],
  );
}

final appRouter = createAppRouter();
