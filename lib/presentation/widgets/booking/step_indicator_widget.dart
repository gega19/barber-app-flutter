import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';

/// Widget para mostrar el indicador de pasos del proceso de reserva
class StepIndicatorWidget extends StatelessWidget {
  final int currentStep;
  final List<StepData> steps;

  const StepIndicatorWidget({
    super.key,
    required this.currentStep,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isActive = index == currentStep;
          final isCompleted = index < currentStep;

          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 2,
                        color: isCompleted || isActive
                            ? AppColors.primaryGold
                            : AppColors.textSecondary.withValues(alpha: 0.3),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isActive || isCompleted
                            ? AppColors.primaryGold
                            : AppColors.backgroundCardDark,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isActive || isCompleted
                              ? AppColors.primaryGold
                              : AppColors.borderGold,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        step.icon,
                        color: isActive || isCompleted
                            ? AppColors.textDark
                            : AppColors.textSecondary,
                        size: 18,
                      ),
                    )
                        .animate(key: ValueKey('step_$index'))
                        .scale(begin: isActive ? const Offset(0.8, 0.8) : const Offset(1, 1), end: const Offset(1, 1), duration: 300.ms),
                    if (index < steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isCompleted
                              ? AppColors.primaryGold
                              : AppColors.textSecondary.withValues(alpha: 0.3),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  step.label,
                  style: TextStyle(
                    color: isActive
                        ? AppColors.primaryGold
                        : AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Datos para cada paso del indicador
class StepData {
  final IconData icon;
  final String label;

  const StepData({required this.icon, required this.label});
}
