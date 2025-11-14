import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'appointment_stats_widget.dart';

/// Widget para el header de la pantalla de citas
class AppointmentHeaderWidget extends StatelessWidget {
  final bool isBarber;

  const AppointmentHeaderWidget({
    super.key,
    required this.isBarber,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Citas',
            style: TextStyle(
              color: AppColors.primaryGold,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isBarber
                ? 'Tus citas programadas y completadas'
                : 'Tus citas pasadas y futuras',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          AppointmentStatsWidget(),
        ],
      ),
    );
  }
}

