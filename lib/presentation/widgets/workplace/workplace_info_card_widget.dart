import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../common/app_card.dart';

/// Widget para mostrar la tarjeta de información (dirección) de la barbería
class WorkplaceInfoCardWidget extends StatelessWidget {
  final String address;

  const WorkplaceInfoCardWidget({
    super.key,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.location_on,
              color: AppColors.primaryGold,
              size: 24,
            ),
            const SizedBox(height: 8),
            const Text(
              'Dirección',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              address,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

