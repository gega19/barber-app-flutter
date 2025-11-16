import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/injection/injection.dart';
import '../../cubit/barber/barber_cubit.dart';
import '../../cubit/appointment/appointment_cubit.dart';
import '../../cubit/promotion/promotion_cubit.dart';
import '../../cubit/workplace/workplace_cubit.dart';
import '../home/home_screen.dart';
import '../discover/discover_screen.dart';
import '../history/history_screen.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const DiscoverScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  void _refreshTabData(BuildContext context, int index) {
    // Refresh data based on the selected tab
    switch (index) {
      case 0: // Home
        context.read<BarberCubit>().loadBestBarbers();
        context.read<WorkplaceCubit>().loadWorkplaces();
        break;
      case 1: // Discover
        context.read<PromotionCubit>().loadPromotions();
        context.read<WorkplaceCubit>().loadWorkplaces();
        context.read<BarberCubit>().loadBarbers();
        break;
      case 2: // Citas
        context.read<AppointmentCubit>().loadAppointments();
        break;
      case 3: // Profile
        // Profile doesn't need refresh as it's managed by AuthCubit
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BarberCubit>(create: (_) => sl()),
        BlocProvider<AppointmentCubit>(create: (_) => sl()),
        BlocProvider<PromotionCubit>(create: (_) => sl()),
        BlocProvider<WorkplaceCubit>(create: (_) => sl()),
      ],
      child: Builder(
        builder: (context) {
          // Load initial data after providers are available
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _refreshTabData(context, _currentIndex);
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
                      _buildNavItem(context, Icons.home, 'Inicio', 0),
                      _buildNavItem(context, Icons.explore, 'Descubrir', 1),
                      _buildNavItem(context, Icons.calendar_today, 'Citas', 2),
                      _buildNavItem(context, Icons.person, 'Perfil', 3),
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
        // Refresh data when switching tabs
        _refreshTabData(context, index);
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
