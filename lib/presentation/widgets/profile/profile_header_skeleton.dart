import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';

/// Skeleton loader para el header del perfil
class ProfileHeaderSkeleton extends StatelessWidget {
  const ProfileHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Avatar Skeleton
              Shimmer.fromColors(
                baseColor: AppColors.backgroundCardDark,
                highlightColor: AppColors.primaryGold.withOpacity(0.1),
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.backgroundCardDark,
                    border: Border.all(
                      color: AppColors.borderGold,
                      width: 2,
                    ),
                  ),
                ),
              ),
              // Edit Button Skeleton
              Positioned(
                bottom: 0,
                right: 0,
                child: Shimmer.fromColors(
                  baseColor: AppColors.backgroundCardDark,
                  highlightColor: AppColors.primaryGold.withOpacity(0.1),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.backgroundCardDark,
                      border: Border.all(
                        color: AppColors.borderGold,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Name Skeleton
          Shimmer.fromColors(
            baseColor: AppColors.backgroundCardDark,
            highlightColor: AppColors.primaryGold.withOpacity(0.1),
            child: Container(
              height: 24,
              width: 200,
              decoration: BoxDecoration(
                color: AppColors.backgroundCardDark,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Email Skeleton
          Shimmer.fromColors(
            baseColor: AppColors.backgroundCardDark,
            highlightColor: AppColors.primaryGold.withOpacity(0.1),
            child: Container(
              height: 14,
              width: 180,
              decoration: BoxDecoration(
                color: AppColors.backgroundCardDark,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

