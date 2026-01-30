import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Widget para mostrar estado vacío con icono y opción de refresh
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRefresh;

  /// Icono opcional; si no se pasa, se usa uno por defecto
  final IconData? icon;

  /// Texto secundario (ej. "Desliza para actualizar")
  final String? subtitle;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.onRefresh,
    this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final displayIcon = icon ?? Icons.search_off_rounded;
    final content = Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              displayIcon,
              size: 72,
              color: AppColors.textSecondary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
            ] else if (onRefresh != null) ...[
              const SizedBox(height: 8),
              Text(
                'Desliza hacia abajo para actualizar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: () async => onRefresh!(),
        color: AppColors.primaryGold,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: content,
          ),
        ),
      );
    }

    return content;
  }
}
