import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/common/app_button.dart';

/// Botones de navegación para el onboarding
class OnboardingButtons extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onGetStarted;

  const OnboardingButtons({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
    required this.onSkip,
    required this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    final isLastPage = currentPage == totalPages - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        children: [
          // Botón principal
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: isLastPage ? 'Empezar' : 'Siguiente',
              onPressed: isLastPage ? onGetStarted : onNext,
              type: ButtonType.primary,
              icon: isLastPage ? Icons.arrow_forward : Icons.arrow_forward_ios,
            ),
          )
              .animate(target: 1)
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideY(
                begin: 0.3,
                end: 0,
                duration: 400.ms,
                delay: 200.ms,
                curve: Curves.easeOut,
              ),

          // Botón saltar (solo si no es la última página)
          if (!isLastPage) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: onSkip,
              child: const Text(
                'Saltar',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            )
                .animate(target: 1)
                .fadeIn(duration: 400.ms, delay: 300.ms),
          ],
        ],
      ),
    );
  }
}

