import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../common/app_card.dart';
import 'profile_settings_row_widget.dart';

/// Widget para mostrar la tarjeta de configuración
class ProfileSettingsCardWidget extends StatelessWidget {
  final bool isBarber;
  final VoidCallback onDeleteAccount;

  const ProfileSettingsCardWidget({
    super.key,
    required this.isBarber,
    required this.onDeleteAccount,
  });

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
                'Configuración',
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
                    if (!isBarber)
                      ProfileSettingsRowWidget(
                        key: const ValueKey('become_barber'),
                        icon: Icons.content_cut,
                        title: 'Convertirse en Barbero',
                        subtitle: 'Comienza a ofrecer tus servicios',
                        onTap: () {
                          context.push('/become-barber');
                        },
                      )
                          .animate()
                          .fadeIn(duration: 300.ms, delay: 50.ms)
                          .slideX(begin: -0.05, end: 0, duration: 300.ms, delay: 50.ms),
                    if (!isBarber) Divider(color: AppColors.borderGold),
                    ProfileSettingsRowWidget(
                      key: const ValueKey('preferences'),
                      icon: Icons.settings,
                      title: 'Preferencias',
                      subtitle: 'Configura tus preferencias',
                      onTap: () {},
                    )
                        .animate()
                        .fadeIn(duration: 300.ms, delay: 100.ms)
                        .slideX(begin: -0.05, end: 0, duration: 300.ms, delay: 100.ms),
                    Divider(color: AppColors.borderGold),
                    ProfileSettingsRowWidget(
                      key: const ValueKey('notifications'),
                      icon: Icons.notifications,
                      title: 'Notificaciones',
                      subtitle: 'Gestiona tus notificaciones',
                      onTap: () {},
                    )
                        .animate()
                        .fadeIn(duration: 300.ms, delay: 150.ms)
                        .slideX(begin: -0.05, end: 0, duration: 300.ms, delay: 150.ms),
                    Divider(color: AppColors.borderGold),
                    ProfileSettingsRowWidget(
                      key: const ValueKey('security'),
                      icon: Icons.lock,
                      title: 'Seguridad',
                      subtitle: 'Autenticación biométrica y seguridad',
                      onTap: () {
                        context.push('/security-settings');
                      },
                    )
                        .animate()
                        .fadeIn(duration: 300.ms, delay: 200.ms)
                        .slideX(begin: -0.05, end: 0, duration: 300.ms, delay: 200.ms),
                    Divider(color: AppColors.borderGold),
                    ProfileSettingsRowWidget(
                      key: const ValueKey('delete_account'),
                      icon: Icons.delete_forever,
                      title: 'Eliminar Cuenta',
                      subtitle: 'Elimina permanentemente tu cuenta',
                      onTap: onDeleteAccount,
                      iconColor: AppColors.error,
                      iconBackgroundColor: AppColors.error.withOpacity(0.15),
                      titleColor: AppColors.error,
                      subtitleColor: AppColors.error,
                    )
                        .animate()
                        .fadeIn(duration: 300.ms, delay: 250.ms)
                        .slideX(begin: -0.05, end: 0, duration: 300.ms, delay: 250.ms),
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

