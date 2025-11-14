import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/promotion_entity.dart';
import '../common/app_card.dart';
import '../common/app_badge.dart';

/// Widget reutilizable para mostrar una promoción
class PromotionCard extends StatelessWidget {
  final PromotionEntity promotion;
  static final _dateFormat = DateFormat('d MMM yyyy', 'es_ES');

  const PromotionCard({super.key, required this.promotion});

  String get _discountText {
    if (promotion.discount != null) {
      return '${promotion.discount!.toStringAsFixed(0)}% OFF';
    } else if (promotion.discountAmount != null) {
      return '\$${promotion.discountAmount!.toStringAsFixed(0)} OFF';
    }
    return '';
  }

  String get _formattedValidUntil {
    return _dateFormat.format(promotion.validUntil);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AppCard(
        padding: const EdgeInsets.all(16),
        onTap: promotion.barber != null
            ? () {
                context.push('/barber/${promotion.barber!.id}');
              }
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    promotion.title,
                    style: const TextStyle(
                      color: AppColors.primaryGold,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (_discountText.isNotEmpty)
                  AppBadge(text: _discountText, type: BadgeType.success)
                else
                  AppBadge(text: 'Activa', type: BadgeType.primary),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              promotion.description,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            if (promotion.barber != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.person,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Válido con ${promotion.barber!.name}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCardDark,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primaryGold,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Text(
                      promotion.code,
                      style: const TextStyle(
                        color: AppColors.primaryGold,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Válido hasta $_formattedValidUntil',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
