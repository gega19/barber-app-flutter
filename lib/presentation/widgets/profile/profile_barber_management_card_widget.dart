import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../common/app_card.dart';
import 'profile_settings_row_widget.dart';

/// Widget para mostrar la tarjeta de gestión de perfil de barbero
class ProfileBarberManagementCardWidget extends StatelessWidget {
  final String? userBarberId;

  const ProfileBarberManagementCardWidget({
    super.key,
    required this.userBarberId,
  });

  @override
  Widget build(BuildContext context) {
    if (userBarberId == null) {
      return const SizedBox.shrink();
    }

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'Gestión de Perfil',
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
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ProfileSettingsRowWidget(
                    key: ValueKey('view_profile_$userBarberId'),
                    icon: Icons.visibility,
                    title: 'Ver mi perfil público',
                    subtitle: 'Cómo ven tu perfil los demás',
                    onTap: () {
                      context.push('/barber/$userBarberId');
                    },
                  )
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 50.ms)
                      .slideX(begin: -0.05, end: 0, duration: 300.ms, delay: 50.ms),
                  Divider(color: AppColors.borderGold),
                  ProfileSettingsRowWidget(
                    key: const ValueKey('barber_info'),
                    icon: Icons.badge,
                    title: 'Información Profesional',
                    subtitle: 'Editar especialidad, experiencia y ubicación',
                    onTap: () {
                      context.push('/barber-info');
                    },
                  )
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 100.ms)
                      .slideX(begin: -0.05, end: 0, duration: 300.ms, delay: 100.ms),
                  Divider(color: AppColors.borderGold),
                  ProfileSettingsRowWidget(
                    key: const ValueKey('barber_services'),
                    icon: Icons.content_cut,
                    title: 'Mis Servicios',
                    subtitle: 'Editar, agregar o eliminar servicios',
                    onTap: () {
                      context.push('/barber-services');
                    },
                  )
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 150.ms)
                      .slideX(begin: -0.05, end: 0, duration: 300.ms, delay: 150.ms),
                  Divider(color: AppColors.borderGold),
                  ProfileSettingsRowWidget(
                    key: const ValueKey('barber_media'),
                    icon: Icons.photo_library,
                    title: 'Mi Multimedia',
                    subtitle: 'Editar, agregar o eliminar fotos y videos',
                    onTap: () {
                      context.push('/barber-media');
                    },
                  )
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 200.ms)
                      .slideX(begin: -0.05, end: 0, duration: 300.ms, delay: 200.ms),
                  Divider(color: AppColors.borderGold),
                  ProfileSettingsRowWidget(
                    key: const ValueKey('barber_availability'),
                    icon: Icons.access_time,
                    title: 'Mi Horario',
                    subtitle: 'Configura tus días y horas disponibles',
                    onTap: () {
                      context.push('/barber-availability');
                    },
                  )
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 250.ms)
                      .slideX(begin: -0.05, end: 0, duration: 300.ms, delay: 250.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

