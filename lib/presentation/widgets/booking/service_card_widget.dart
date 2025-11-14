import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/service_model.dart';
import '../../../data/models/promotion_model.dart';
import '../../../core/utils/booking_utils.dart';
import '../common/app_card.dart';

/// Widget para mostrar una tarjeta de servicio individual
class ServiceCardWidget extends StatelessWidget {
  final ServiceModel service;
  final bool isSelected;
  final PromotionModel? activePromotion;
  final VoidCallback onTap;

  const ServiceCardWidget({
    super.key,
    required this.service,
    required this.isSelected,
    this.activePromotion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final priceBreakdown = BookingUtils.calculatePriceBreakdown(
      service: service,
      barberPrice: service.price,
      promotion: activePromotion,
    );
    final finalPrice = priceBreakdown['totalPrice']!;
    final hasDiscount = priceBreakdown['discountAmount']! > 0;

    return RepaintBoundary(
      child: Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AppCard(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryGold.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryGold
                    : AppColors.borderGold,
                width: isSelected ? 2 : 1,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryGold
                        : AppColors.backgroundCardDark,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.cut,
                    color: isSelected
                        ? AppColors.textDark
                        : AppColors.primaryGold,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primaryGold
                              : AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (service.description != null &&
                          service.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          service.description!,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (hasDiscount)
                      Text(
                        '\$${service.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    Text(
                      '\$${finalPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primaryGold
                            : AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

