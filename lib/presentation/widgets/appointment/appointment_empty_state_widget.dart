import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';

/// Widget para mostrar el estado vacío de citas
class AppointmentEmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String message;
  final String submessage;

  const AppointmentEmptyStateWidget({
    super.key,
    required this.icon,
    required this.message,
    required this.submessage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            )
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 400))
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1, 1),
                  duration: const Duration(milliseconds: 400),
                ),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 200),
                )
                .slideY(
                  begin: 0.1,
                  end: 0,
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 200),
                ),
            const SizedBox(height: 8),
            Text(
              submessage,
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }
}

