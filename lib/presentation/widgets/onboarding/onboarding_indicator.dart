import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';

/// Indicadores de página para el onboarding
class OnboardingIndicator extends StatelessWidget {
  final int currentIndex;
  final int totalPages;

  const OnboardingIndicator({
    super.key,
    required this.currentIndex,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => _buildDot(index == currentIndex),
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 32 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primaryGold
            : AppColors.primaryGold.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    )
        .animate(target: isActive ? 1 : 0)
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.2, 1.2),
          duration: 300.ms,
        );
  }
}

