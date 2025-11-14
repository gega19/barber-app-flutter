import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/appointment_entity.dart';
import '../common/app_card.dart';
import '../common/app_avatar.dart';

/// Widget para mostrar la tarjeta de perfil en el detalle de cita
class AppointmentProfileCardWidget extends StatelessWidget {
  final AppointmentEntity appointment;
  final bool isBarber;

  const AppointmentProfileCardWidget({
    super.key,
    required this.appointment,
    required this.isBarber,
  });

  @override
  Widget build(BuildContext context) {
    String? avatarUrl;
    String? avatarSeed;
    String name;
    String? specialtyOrPhone;
    String? email;

    if (isBarber) {
      name = appointment.client?.name ?? 'Cliente desconocido';
      avatarUrl = appointment.client?.avatar;
      avatarSeed = appointment.client?.avatarSeed;
      specialtyOrPhone = appointment.client?.phone;
      email = appointment.client?.email;
    } else {
      name = appointment.barber?.name ?? 'Barbero desconocido';
      avatarUrl = appointment.barber?.image;
      avatarSeed = appointment.barber?.avatarSeed;
      specialtyOrPhone = appointment.barber?.specialty;
    }

    return RepaintBoundary(
      child: AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          AppAvatar(
            imageUrl: avatarUrl,
            name: name,
            avatarSeed: avatarSeed,
            size: 96,
            borderColor: AppColors.primaryGold,
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (specialtyOrPhone != null) ...[
            const SizedBox(height: 8),
            Text(
              specialtyOrPhone,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
          if (email != null) ...[
            const SizedBox(height: 4),
            Text(
              email,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
      ),
    );
  }
}

