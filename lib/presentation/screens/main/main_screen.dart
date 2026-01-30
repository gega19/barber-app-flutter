import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/injection/injection.dart';
import '../../cubit/barber/barber_cubit.dart';
import '../../cubit/appointment/appointment_cubit.dart';
import '../../cubit/promotion/promotion_cubit.dart';
import '../../cubit/workplace/workplace_cubit.dart';
import '../../cubit/map/map_cubit.dart';
import '../home/home_screen.dart';
import '../discover/discover_screen.dart';
import '../map/barbershops_map_screen.dart';
import '../history/history_screen.dart';
import '../profile/profile_screen.dart';

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
  int _previousIndex = -1; // Track previous index to avoid re-loading

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
            }
          });

          return Scaffold(
            body: IndexedStack(index: _currentIndex, children: _screens),
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
                      _buildNavItem(builderContext, Icons.home, 'Inicio', 0),
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
                      _buildNavItem(builderContext, Icons.person, 'Perfil', 4),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _loadTabData(BuildContext context, int index) {
    // Avoid reloading the same tab
    if (index == _previousIndex) return;

    // Load data based on the selected tab
    switch (index) {
      case 0: // Home
        context.read<BarberCubit>().loadBarbers(reset: true);
        context.read<WorkplaceCubit>().loadWorkplaces();
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
        context.read<AppointmentCubit>().loadAppointments();
        break;
      case 4: // Profile
        // Profile doesn't need refresh as it's managed by AuthCubit
        break;
    }

    _previousIndex = index;
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
        setState(() {
          _currentIndex = index;
        });
        // Load data for new tab
        _loadTabData(context, index);
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
