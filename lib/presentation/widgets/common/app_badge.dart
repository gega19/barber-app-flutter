import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Badge reutilizable
class AppBadge extends StatelessWidget {
  final String text;
  final BadgeType type;
  final IconData? icon;

  const AppBadge({
    super.key,
    required this.text,
    this.type = BadgeType.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors['background'],
        borderRadius: BorderRadius.circular(20),
        border: type == BadgeType.outline
            ? Border.all(color: colors['text'] as Color, width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: colors['text'] as Color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: colors['text'] as Color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, Color> _getColors() {
    switch (type) {
      case BadgeType.primary:
        return {
          'background': AppColors.primaryGold,
          'text': AppColors.textDark,
        };
      case BadgeType.success:
        return {
          'background': AppColors.success.withValues(alpha: 0.2),
          'text': AppColors.success,
        };
      case BadgeType.error:
        return {
          'background': AppColors.error.withValues(alpha: 0.2),
          'text': AppColors.error,
        };
      case BadgeType.outline:
        return {
          'background': Colors.transparent,
          'text': AppColors.textPrimary,
        };
    }
  }
}

enum BadgeType { primary, success, error, outline }


