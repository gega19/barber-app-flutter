import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/promotion_model.dart';

/// Widget para mostrar el banner de promoción activa
class PromotionBannerWidget extends StatelessWidget {
  final PromotionModel promotion;

  const PromotionBannerWidget({super.key, required this.promotion});

  @override
  Widget build(BuildContext context) {
    final discountText = promotion.discount != null
        ? '${promotion.discount!.toStringAsFixed(0)}% OFF'
        : promotion.discountAmount != null
        ? '\$${promotion.discountAmount!.toStringAsFixed(0)} OFF'
        : 'PROMOCIÓN';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGold.withValues(alpha: 0.2),
            AppColors.primaryGold.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryGold, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryGold,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_offer,
                color: AppColors.textDark,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        discountText,
                        style: const TextStyle(
                          color: AppColors.primaryGold,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'ACTIVA',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    promotion.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (promotion.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      promotion.description,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
