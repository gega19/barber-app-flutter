import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/appointment_utils.dart';
import '../../../domain/entities/appointment_entity.dart';
import '../common/app_badge.dart';

/// Widget para el header del detalle de cita
class AppointmentDetailHeaderWidget extends StatelessWidget {
  final AppointmentEntity appointment;

  const AppointmentDetailHeaderWidget({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final statusConfig = AppointmentUtils.getStatusConfig(appointment.status);

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.borderGold, width: 1),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.backgroundCardDark,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderGold),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppColors.primaryGold,
                  size: 20,
                ),
              ),
              onPressed: () => context.pop(),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Detalle de Cita',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            AppBadge(
              text: statusConfig['label'] as String,
              type: statusConfig['badgeType'] as BadgeType,
            ),
          ],
        ),
      ),
    );
  }
}
