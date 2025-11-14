import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../common/app_card.dart';

/// Widget para mostrar la tarjeta de experiencia del barbero
class BarberExperienceCardWidget extends StatelessWidget {
  final String experience;

  const BarberExperienceCardWidget({super.key, required this.experience});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(
              Icons.work_outline,
              color: AppColors.primaryGold,
              size: 20,
            ),
            const SizedBox(width: 12),
            const Text(
              'Experiencia',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(width: 8),
            Text(
              '$experience años',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
