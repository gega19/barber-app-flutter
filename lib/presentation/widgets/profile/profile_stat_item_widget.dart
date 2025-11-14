import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Widget para mostrar un item individual de estadística
class ProfileStatItemWidget extends StatelessWidget {
  final String value;
  final String label;

  const ProfileStatItemWidget({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

