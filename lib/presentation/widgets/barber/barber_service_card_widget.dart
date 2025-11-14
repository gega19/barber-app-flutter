import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/service_model.dart';

/// Widget para mostrar una tarjeta de servicio individual
class BarberServiceCardWidget extends StatelessWidget {
  final ServiceModel service;

  const BarberServiceCardWidget({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGold),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  service.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '\$${service.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (service.description != null && service.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              service.description!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
          if (service.includes != null && service.includes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.primaryGold,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Incluye: ${service.includes}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      ),
    );
  }
}

