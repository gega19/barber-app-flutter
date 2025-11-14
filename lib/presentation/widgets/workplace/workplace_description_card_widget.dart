import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../common/app_card.dart';

/// Widget para mostrar la tarjeta de descripción de la barbería
class WorkplaceDescriptionCardWidget extends StatelessWidget {
  final String description;

  const WorkplaceDescriptionCardWidget({
    super.key,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Descripción',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

