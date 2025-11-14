import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../common/app_card.dart';

/// Skeleton loader para PaymentMethodCardWidget
class PaymentMethodCardSkeleton extends StatelessWidget {
  const PaymentMethodCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: EdgeInsets.zero,
        child: Shimmer.fromColors(
          baseColor: AppColors.backgroundCardDark,
          highlightColor: AppColors.primaryGold.withOpacity(0.1),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon skeleton
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 16),
                // Name skeleton
                Expanded(
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

