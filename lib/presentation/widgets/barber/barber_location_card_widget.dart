import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../common/app_card.dart';

/// Widget para mostrar la tarjeta de ubicación del barbero
class BarberLocationCardWidget extends StatelessWidget {
  final String location;

  const BarberLocationCardWidget({
    super.key,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.location_on,
            color: AppColors.primaryGold,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ubicación',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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

