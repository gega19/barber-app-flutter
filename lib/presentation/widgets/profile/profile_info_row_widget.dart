import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/profile_utils.dart';

/// Widget para mostrar una fila de información editable
class ProfileInfoRowWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isEditable;
  final String? fieldType;
  final VoidCallback? onEdit;

  const ProfileInfoRowWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.isEditable,
    this.fieldType,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primaryGold,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ProfileUtils.getDisplayValue(value),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (isEditable && onEdit != null)
              IconButton(
                icon: const Icon(
                  Icons.edit,
                  color: AppColors.primaryGold,
                  size: 20,
                ),
                onPressed: onEdit,
              ),
          ],
        ),
      ),
    );
  }
}

