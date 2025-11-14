import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../common/app_card.dart';

/// Skeleton loader para tarjetas de barberos
class WorkplaceBarberCardSkeleton extends StatelessWidget {
  const WorkplaceBarberCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.backgroundCardDark,
      highlightColor: AppColors.primaryGold.withOpacity(0.1),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            // Avatar Skeleton
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.backgroundCardDark,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name Skeleton
                  Container(
                    height: 16,
                    width: 150,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCardDark,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Specialty Skeleton
                  Container(
                    height: 14,
                    width: 100,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCardDark,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Rating Skeleton
                  Container(
                    height: 14,
                    width: 60,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCardDark,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

