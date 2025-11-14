import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/appointment_utils.dart';
import '../../../domain/entities/appointment_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../common/app_card.dart';
import '../common/app_avatar.dart';
import '../common/app_badge.dart';

/// Widget reutilizable para mostrar una tarjeta de cita
class AppointmentCard extends StatelessWidget {
  final AppointmentEntity appointment;
  final bool isBarber;
  final UserEntity? currentUser;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.isBarber,
    this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: _buildCard(context));
  }

  Widget _buildCard(BuildContext context) {
    final statusConfig = AppointmentUtils.getStatusConfig(appointment.status);
    final dateFormat = AppointmentUtils.formatAppointmentDate(appointment.date);

    String? avatarUrl;
    String? avatarSeed;
    String name;
    String? specialtyOrPhone;

    if (isBarber) {
      name = appointment.client?.name ?? 'Cliente desconocido';
      avatarUrl = appointment.client?.avatar;
      avatarSeed = appointment.client?.avatarSeed;
      specialtyOrPhone = appointment.client?.phone;
    } else {
      name = appointment.barber?.name ?? 'Barbero desconocido';
      avatarUrl = appointment.barber?.image;
      avatarSeed = appointment.barber?.avatarSeed;
      specialtyOrPhone = appointment.barber?.specialty;
    }

    return AppCard(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      onTap: () {
        context.push('/appointment/${appointment.id}');
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppAvatar(
            imageUrl: avatarUrl,
            name: name,
            avatarSeed: avatarSeed,
            size: 64,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    AppBadge(
                      text: statusConfig['label'] as String,
                      type: statusConfig['badgeType'] as BadgeType,
                    ),
                  ],
                ),
                if (specialtyOrPhone != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    specialtyOrPhone,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        dateFormat,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      appointment.time,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                if (appointment.paymentMethod != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.payment,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        appointment.paymentMethodName ??
                            AppointmentUtils.getPaymentMethodLabel(
                              appointment.paymentMethod!,
                            ),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
