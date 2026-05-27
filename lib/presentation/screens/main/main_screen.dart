import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/injection/injection.dart';
import '../../cubit/barber/barber_cubit.dart';
import '../../cubit/appointment/appointment_cubit.dart';
import '../../cubit/promotion/promotion_cubit.dart';
import '../../cubit/workplace/workplace_cubit.dart';
import '../../cubit/map/map_cubit.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../../cubit/barber/favorites/favorites_cubit.dart';
import '../home/home_screen.dart';
import '../discover/discover_screen.dart';
import '../map/barbershops_map_screen.dart';
import '../history/history_screen.dart';
import '../profile/profile_screen.dart';
import '../../widgets/home/upcoming_appointment_banner.dart';
import '../../widgets/auth/guest_login_prompt.dart';
import '../../widgets/auth/country_confirm_dialog.dart';

/// MainScreen - Root container with bottom navigation
///
/// Responsibilities:
/// - Provide BlocProviders for all child screens
/// - Handle bottom navigation bar
/// - Manage tab switching with IndexedStack
/// - Load data only for visible tab (prevents duplicate loads)
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int _previousIndex = -1;
  bool _countryPromptShown = false;

  final List<Widget> _screens = [
    const HomeScreen(),
    const DiscoverScreen(),
    const BarbershopsMapScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BarberCubit>(create: (_) => sl()),
        BlocProvider<AppointmentCubit>(create: (_) => sl()),
        BlocProvider<PromotionCubit>(create: (_) => sl()),
        BlocProvider<WorkplaceCubit>(create: (_) => sl()),
        BlocProvider<MapCubit>(create: (_) => sl()),
      ],
      // Use Builder to get context WITH provider access
      child: Builder(
        builder: (builderContext) {
          // Load initial tab data once
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _previousIndex == -1) {
              _loadTabData(builderContext, 0);
              _checkSuggestedCountry(builderContext);
              _ensureAppointmentsIfSignedIn(builderContext);
            }
          });

          return BlocListener<AuthCubit, AuthState>(
            listenWhen: (prev, curr) =>
                curr is AuthInitial &&
                (prev is AuthAuthenticated ||
                    prev is AuthProfileUpdateError ||
                    prev is AuthLoading),
            listener: (context, state) =>
                _onSessionEndedAsGuest(builderContext),
            child: BlocListener<AuthCubit, AuthState>(
              listenWhen: (prev, curr) {
                if (curr is! AuthAuthenticated) return false;
                if (prev is! AuthAuthenticated) return true;
                return prev.user.country != curr.user.country ||
                    prev.user.suggestedCountry != curr.user.suggestedCountry;
              },
              listener: (context, state) {
                if (state is AuthAuthenticated) {
                  _maybeShowCountryPrompt(context, state);
                  context.read<BarberCubit>().loadBarbers(reset: true);
                  context.read<WorkplaceCubit>().loadWorkplaces(reset: true);
                  context.read<AppointmentCubit>().loadAppointments();
                  if (_currentIndex == 2) {
                    context.read<MapCubit>().getUserLocation();
                  }
                }
              },
              child: Scaffold(
                body: Column(
                  children: [
                    Expanded(
                      child: IndexedStack(
                        index: _currentIndex,
                        children: _screens,
                      ),
                    ),
                    const UpcomingAppointmentBanner(),
                  ],
                ),
                bottomNavigationBar: Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    border: Border(
                      top: BorderSide(color: AppColors.primaryGold, width: 2),
                    ),
                  ),
                  child: SafeArea(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNavItem(
                            builderContext,
                            Icons.home,
                            'Inicio',
                            0,
                          ),
                          _buildNavItem(
                            builderContext,
                            Icons.explore,
                            'Descubrir',
                            1,
                          ),
                          _buildNavItem(builderContext, Icons.map, 'Mapa', 2),
                          _buildNavItem(
                            builderContext,
                            Icons.calendar_today,
                            'Citas',
                            3,
                          ),
                          _buildNavItem(
                            builderContext,
                            Icons.person,
                            'Perfil',
                            4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onSessionEndedAsGuest(BuildContext context) {
    if (!mounted) return;
    setState(() {
      _currentIndex = 0;
      _countryPromptShown = false;
    });
    try {
      context.read<AppointmentCubit>().clear();
      sl<FavoritesCubit>().clearSession();
      context.read<BarberCubit>().loadBarbers(reset: true);
      context.read<WorkplaceCubit>().loadWorkplaces(reset: true);
    } catch (_) {
      /* providers disponibles dentro de MainScreen */
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadTabData(context, 0, forceRefresh: true);
    });
  }

  void _loadTabData(
    BuildContext context,
    int index, {
    bool forceRefresh = false,
  }) {
    // Avoid reloading the same tab unless forced
    if (index == _previousIndex && !forceRefresh) return;

    final authSnapshot = context.read<AuthCubit>().state;
    final hasAccount =
        authSnapshot is AuthAuthenticated ||
        authSnapshot is AuthProfileUpdateError;

    // Load data based on the selected tab
    switch (index) {
      case 0: // Home
        context.read<BarberCubit>().loadBarbers(reset: true);
        context.read<WorkplaceCubit>().loadWorkplaces();
        if (hasAccount) {
          context.read<AppointmentCubit>().loadAppointments();
        }
        break;
      case 1: // Discover
        context.read<PromotionCubit>().loadPromotions();
        context.read<WorkplaceCubit>().loadWorkplaces();
        context.read<BarberCubit>().loadBarbers(reset: true);
        break;
      case 2: // Mapa
        context.read<MapCubit>().getUserLocation();
        break;
      case 3: // Citas
        if (hasAccount) {
          context.read<AppointmentCubit>().loadAppointments();
        }
        break;
      case 4: // Profile
        // Profile doesn't need refresh as it's managed by AuthCubit
        break;
    }

    _previousIndex = index;
  }

  /// Carga citas para barberos/clientes cuando ya hay sesión (banner en Home).
  void _ensureAppointmentsIfSignedIn(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated || authState is AuthProfileUpdateError) {
      final aptState = context.read<AppointmentCubit>().state;
      final alreadyLoaded = aptState is AppointmentLoaded;
      final alreadyLoading = aptState is AppointmentLoading;
      if (!alreadyLoaded && !alreadyLoading) {
        context.read<AppointmentCubit>().loadAppointments();
      }
    }
  }

  void _maybeShowCountryPrompt(BuildContext context, AuthAuthenticated state) {
    if (_countryPromptShown) return;
    final user = state.user;
    if (user.country == null && user.suggestedCountry != null) {
      _countryPromptShown = true;
      CountryConfirmDialog.show(
        context,
        suggestedCountryCode: user.suggestedCountry!,
      );
    }
  }

  void _checkSuggestedCountry(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      _maybeShowCountryPrompt(context, authState);
    }
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
  ) {
    final isActive = _currentIndex == index;

    return InkWell(
      onTap: () {
        // Verificar si es invitado intentando acceder a rutas protegidas
        if (index == 3 || index == 4) {
          final authState = context.read<AuthCubit>().state;
          final isAuthenticated = authState is AuthAuthenticated;

          if (!isAuthenticated) {
            GuestLoginPrompt.show(
              context,
              message: index == 3
                  ? 'Regístrate o inicia sesión para gestionar tus citas médicas o de barbería.'
                  : 'Crea tu perfil para guardar tus barberos favoritos y ver tu historial.',
            );
            return;
          }
        }

        if (_currentIndex == index) {
          // If tapping the already active tab, force a refresh
          _loadTabData(context, index, forceRefresh: true);
        } else {
          setState(() {
            _currentIndex = index;
          });
          // Load data for new tab
          _loadTabData(context, index);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primaryGold.withValues(alpha: 0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isActive
                    ? AppColors.primaryGold
                    : AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? AppColors.primaryGold
                    : AppColors.textSecondary,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 40,
                height: 2,
                decoration: BoxDecoration(
                  color: AppColors.primaryGold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
