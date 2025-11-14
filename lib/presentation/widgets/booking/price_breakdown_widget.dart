import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/promotion_model.dart';

/// Widget para mostrar el desglose de precios con descuentos
class PriceBreakdownWidget extends StatelessWidget {
  final double basePrice;
  final double discountAmount;
  final double totalPrice;
  final PromotionModel? promotion;

  const PriceBreakdownWidget({
    super.key,
    required this.basePrice,
    required this.discountAmount,
    required this.totalPrice,
    this.promotion,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = discountAmount > 0;

    return RepaintBoundary(
      child: Column(
      children: [
        if (hasDiscount && promotion != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundCardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderGold),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Precio original',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '\$${basePrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.local_offer,
                          color: AppColors.primaryGold,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          promotion!.discount != null
                              ? '${promotion!.discount!.toStringAsFixed(0)}% OFF'
                              : 'Descuento',
                          style: const TextStyle(
                            color: AppColors.primaryGold,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '-\$${discountAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppColors.primaryGold,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryGold.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryGold),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total a pagar',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${totalPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
      ),
    );
  }
}

