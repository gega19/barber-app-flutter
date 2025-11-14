import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/injection/injection.dart';
import '../../../data/datasources/local/local_storage.dart';
import '../common/app_card.dart';
import 'profile_settings_row_widget.dart';

/// Widget para mostrar la tarjeta de "Otros"
class ProfileOthersCardWidget extends StatelessWidget {
  const ProfileOthersCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'Otros',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .slideX(begin: -0.1, end: 0, duration: 300.ms),
            RepaintBoundary(
              child: AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ProfileSettingsRowWidget(
                      key: const ValueKey('tutorial'),
                      icon: Icons.school,
                      title: 'Ver Tutorial',
                      subtitle: 'Revisa la guía de bienvenida',
                      onTap: () async {
                        final localStorage = sl<LocalStorage>();
                        await localStorage.setOnboardingCompleted(false);
                        if (context.mounted) {
                          context.go('/onboarding?return=/home');
                        }
                      },
                    )
                        .animate()
                        .fadeIn(duration: 300.ms, delay: 50.ms)
                        .slideX(begin: -0.05, end: 0, duration: 300.ms, delay: 50.ms),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

