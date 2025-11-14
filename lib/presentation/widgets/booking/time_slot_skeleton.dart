import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';

/// Skeleton loader para TimeSlotWidget
class TimeSlotSkeleton extends StatelessWidget {
  const TimeSlotSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.backgroundCardDark,
      highlightColor: AppColors.primaryGold.withOpacity(0.1),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundCardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.borderGold,
            width: 1,
          ),
        ),
        child: Center(
          child: Container(
            width: 50,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
}

