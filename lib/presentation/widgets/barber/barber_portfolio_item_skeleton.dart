import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';

/// Skeleton loader para items del portfolio
class BarberPortfolioItemSkeleton extends StatelessWidget {
  const BarberPortfolioItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.backgroundCardDark,
      highlightColor: AppColors.primaryGold.withOpacity(0.1),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundCardDark,
          border: Border.all(color: AppColors.borderGold),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

