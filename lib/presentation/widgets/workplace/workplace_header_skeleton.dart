import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';

/// Skeleton loader para el header de la barbería
class WorkplaceHeaderSkeleton extends StatelessWidget {
  const WorkplaceHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Stack(
        fit: StackFit.expand,
        children: [
          // Banner Skeleton
          Shimmer.fromColors(
            baseColor: AppColors.backgroundCardDark,
            highlightColor: AppColors.primaryGold.withOpacity(0.1),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.backgroundCard,
                    AppColors.backgroundDark,
                  ],
                ),
              ),
            ),
          ),
          // Gradient Overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 150,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),
          // Profile Info Skeleton
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
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
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                          // City Skeleton
                          Shimmer.fromColors(
                            baseColor: AppColors.backgroundCardDark,
                            highlightColor: AppColors.primaryGold.withOpacity(0.1),
                            child: Container(
                              height: 14,
                              width: 150,
                              decoration: BoxDecoration(
                                color: AppColors.backgroundCardDark,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Rating Skeleton
                          Shimmer.fromColors(
                            baseColor: AppColors.backgroundCardDark,
                            highlightColor: AppColors.primaryGold.withOpacity(0.1),
                            child: Container(
                              height: 16,
                              width: 120,
                              decoration: BoxDecoration(
                                color: AppColors.backgroundCardDark,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

