import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/user_entity.dart';
import '../common/app_card.dart';
import 'profile_info_row_widget.dart';

/// Widget para mostrar la tarjeta de información personal
class ProfileInfoCardWidget extends StatelessWidget {
  final UserEntity user;
  final Function(String, String, String) onEditField;

  const ProfileInfoCardWidget({
    super.key,
    required this.user,
    required this.onEditField,
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
                'Información Personal',
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
                    ProfileInfoRowWidget(
                      key: ValueKey('name_${user.name}'),
                      icon: Icons.person,
                      label: 'Nombre Completo',
                      value: user.name,
                      isEditable: true,
                      fieldType: 'name',
                      onEdit: () => onEditField('Nombre Completo', user.name, 'name'),
                    )
                        .animate()
                        .fadeIn(duration: 300.ms, delay: 50.ms)
                        .slideX(begin: -0.05, end: 0, duration: 300.ms, delay: 50.ms),
                    Divider(color: AppColors.borderGold),
                    ProfileInfoRowWidget(
                      key: ValueKey('email_${user.email}'),
                      icon: Icons.email,
                      label: 'Correo Electrónico',
                      value: user.email,
                      isEditable: false,
                    )
                        .animate()
                        .fadeIn(duration: 300.ms, delay: 100.ms)
                        .slideX(begin: -0.05, end: 0, duration: 300.ms, delay: 100.ms),
                    Divider(color: AppColors.borderGold),
                    ProfileInfoRowWidget(
                      key: ValueKey('phone_${user.phone}'),
                      icon: Icons.phone,
                      label: 'Teléfono',
                      value: user.phone ?? 'No configurado',
                      isEditable: true,
                      fieldType: 'phone',
                      onEdit: () => onEditField('Teléfono', user.phone ?? '', 'phone'),
                    )
                        .animate()
                        .fadeIn(duration: 300.ms, delay: 150.ms)
                        .slideX(begin: -0.05, end: 0, duration: 300.ms, delay: 150.ms),
                    Divider(color: AppColors.borderGold),
                    ProfileInfoRowWidget(
                      key: ValueKey('location_${user.location}'),
                      icon: Icons.location_on,
                      label: 'Ubicación',
                      value: user.location ?? 'No configurado',
                      isEditable: true,
                      fieldType: 'location',
                      onEdit: () => onEditField('Ubicación', user.location ?? '', 'location'),
                    )
                        .animate()
                        .fadeIn(duration: 300.ms, delay: 200.ms)
                        .slideX(begin: -0.05, end: 0, duration: 300.ms, delay: 200.ms),
                    Divider(color: AppColors.borderGold),
                    ProfileInfoRowWidget(
                      key: ValueKey('country_${user.country}'),
                      icon: Icons.public,
                      label: 'País',
                      value: user.country ?? 'No configurado',
                      isEditable: true,
                      fieldType: 'country',
                      onEdit: () => onEditField('País', user.country ?? '', 'country'),
                    )
                        .animate()
                        .fadeIn(duration: 300.ms, delay: 250.ms)
                        .slideX(begin: -0.05, end: 0, duration: 300.ms, delay: 250.ms),
                    Divider(color: AppColors.borderGold),
                    ProfileInfoRowWidget(
                      key: ValueKey('gender_${user.gender}'),
                      icon: Icons.person,
                      label: 'Género',
                      value: user.gender ?? 'No configurado',
                      isEditable: true,
                      fieldType: 'gender',
                      onEdit: () => onEditField('Género', user.gender ?? '', 'gender'),
                    )
                        .animate()
                        .fadeIn(duration: 300.ms, delay: 300.ms)
                        .slideX(begin: -0.05, end: 0, duration: 300.ms, delay: 300.ms),
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

