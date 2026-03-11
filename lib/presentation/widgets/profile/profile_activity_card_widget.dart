import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../common/app_card.dart';
import 'profile_settings_row_widget.dart';

/// Widget para mostrar la tarjeta de "Mi Actividad"
///
/// Si [userBarberId] no es null (el usuario es barbero) muestra además
/// el acceso al Dashboard de analítica.
class ProfileActivityCardWidget extends StatelessWidget {
  final String? userBarberId;

  const ProfileActivityCardWidget({super.key, this.userBarberId});

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
                    'Mi Actividad',
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
                    // ── Dashboard (solo para barberos) ───────────────────
                    if (userBarberId != null) ...[
                      ProfileSettingsRowWidget(
                            icon: Icons.bar_chart_rounded,
                            title: 'Mi Analítica',
                            subtitle: 'Ingresos, citas, clientes y más',
                            onTap: () =>
                                context.push('/barber-dashboard/$userBarberId'),
                            iconColor: AppColors.primaryGold,
                            iconBackgroundColor: AppColors.primaryGold
                                .withValues(alpha: 0.15),
                          )
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .slideX(begin: -0.05, end: 0, duration: 300.ms),
                      Divider(color: AppColors.borderGold),
                    ],

                    // ── Favoritos (todos los usuarios) ───────────────────
                    ProfileSettingsRowWidget(
                          key: const ValueKey('favorites'),
                          icon: Icons.favorite,
                          title: 'Mis Favoritos',
                          subtitle: 'Barberos que te encantan',
                          onTap: () {
                            context.push('/favorites');
                          },
                          iconColor: AppColors.primaryGold,
                          iconBackgroundColor: AppColors.primaryGold.withValues(
                            alpha: 0.15,
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 300.ms, delay: 50.ms)
                        .slideX(
                          begin: -0.05,
                          end: 0,
                          duration: 300.ms,
                          delay: 50.ms,
                        ),
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
