import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../screens/onboarding/onboarding_data.dart';

/// Widget para cada página del onboarding
class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPageData pageData;
  final int pageIndex;
  final int currentIndex;

  const OnboardingPageWidget({
    super.key,
    required this.pageData,
    required this.pageIndex,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = pageIndex == currentIndex;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo (solo en la primera página) o Icono principal (en las demás)
            if (pageIndex == 0)
              // Logo de la app
              Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGold.withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/logo.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 200.ms)
                  .scale(delay: 200.ms, duration: 600.ms)
            else
              // Icono principal para las demás páginas
              Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryGold.withValues(alpha: 0.2),
                          AppColors.primaryGoldDark.withValues(alpha: 0.3),
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.primaryGold.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      pageData.icon,
                      size: 50,
                      color: AppColors.primaryGold,
                    ),
                  )
                  .animate(target: isActive ? 1 : 0)
                  .fadeIn(duration: 600.ms, delay: 300.ms)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    duration: 600.ms,
                    delay: 300.ms,
                    curve: Curves.easeOutBack,
                  ),

            const SizedBox(height: 32),

            // Título
            Text(
                  pageData.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.primaryGold,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                )
                .animate(target: isActive ? 1 : 0)
                .fadeIn(duration: 600.ms, delay: 400.ms)
                .slideY(
                  begin: 0.2,
                  end: 0,
                  duration: 600.ms,
                  delay: 400.ms,
                  curve: Curves.easeOut,
                ),

            const SizedBox(height: 16),

            // Descripción
            Text(
                  pageData.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.5,
                  ),
                )
                .animate(target: isActive ? 1 : 0)
                .fadeIn(duration: 600.ms, delay: 500.ms)
                .slideY(
                  begin: 0.2,
                  end: 0,
                  duration: 600.ms,
                  delay: 500.ms,
                  curve: Curves.easeOut,
                ),
          ],
        ),
      ),
    );
  }
}
