import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/payment_method_entity.dart';
import '../common/app_card.dart';

/// Widget para mostrar una tarjeta de método de pago individual
class PaymentMethodCardWidget extends StatelessWidget {
  final PaymentMethodEntity method;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodCardWidget({
    super.key,
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AppCard(
          padding: EdgeInsets.zero,
          child: Container(
            padding: const EdgeInsets.all(16),
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
            child: Row(
              children: [
                Text(
                  method.icon ?? '💳',
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    method.name,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.primaryGold
                          : AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.primaryGold,
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

