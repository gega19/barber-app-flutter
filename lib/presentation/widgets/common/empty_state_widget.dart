import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Widget para mostrar estado vacío con opción de refresh
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRefresh;

  const EmptyStateWidget({super.key, required this.message, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary),
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
