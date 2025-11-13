import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Widget de tabs para el HomeScreen
class HomeTabs extends StatelessWidget {
  final TabController tabController;

  const HomeTabs({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Tab(text: 'Barberos'),
          Tab(text: 'Barberías'),
        ],
      ),
    );
  }
}
