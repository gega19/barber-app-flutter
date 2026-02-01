import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/appointment_entity.dart';
import '../../common/app_card.dart';

/// Widget que muestra la información del servicio de una cita.
///
/// Muestra el nombre del servicio y su precio de forma clara y atractiva.
class AppointmentServiceCard extends StatelessWidget {
  final AppointmentEntity appointment;

  const AppointmentServiceCard({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        RepaintBoundary(
          child:
              AppCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.cut,
                              color: AppColors.primaryGold,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Servicio',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (appointment.serviceName != null) ...[
                          Text(
                            appointment.serviceName!,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (appointment.price != null) ...[
                          Text(
                            '\$${appointment.price!.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppColors.primaryGold,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 300.ms)
                  .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: 300.ms),
        ),
      ],
    );
  }
}
