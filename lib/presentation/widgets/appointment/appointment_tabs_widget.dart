import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Widget para los tabs de filtrado de citas
class AppointmentTabsWidget extends StatelessWidget {
  final TabController tabController;
  final VoidCallback onTabChanged;

  const AppointmentTabsWidget({
    super.key,
    required this.tabController,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderGold),
      ),
      child: TabBar(
        controller: tabController,
        indicatorColor: AppColors.primaryGold,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColors.textDark,
        unselectedLabelColor: AppColors.textSecondary,
        indicator: BoxDecoration(
          color: AppColors.primaryGold,
          borderRadius: BorderRadius.circular(8),
        ),
        tabs: const [
          Tab(text: 'Todas'),
          Tab(text: 'Próximas'),
          Tab(text: 'Completadas'),
        ],
        onTap: (_) => onTabChanged(),
      ),
    );
  }
}

