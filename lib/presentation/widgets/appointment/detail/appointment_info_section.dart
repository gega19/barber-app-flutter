import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/appointment_utils.dart';
import '../../../../domain/entities/appointment_entity.dart';
import '../appointment_detail_row_widget.dart';
import '../../common/app_badge.dart';
import '../../common/app_card.dart';

/// Widget que muestra la información básica de una cita.
///
/// Incluye: fecha, hora, método de pago, estado y notas.
class AppointmentInfoSection extends StatelessWidget {
  final AppointmentEntity appointment;

  const AppointmentInfoSection({super.key, required this.appointment});

  String _formatEntityDate(AppointmentEntity a) {
    final p = a.dateYmd.split('-').map(int.parse).toList();
    final d = DateTime.utc(p[0], p[1], p[2]);
    return DateFormat('EEEE, d MMMM yyyy', 'es_ES').format(d);
  }

  @override
  Widget build(BuildContext context) {
    final statusConfig = AppointmentUtils.getStatusConfig(appointment.status);

    return RepaintBoundary(
      child:
          AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    AppointmentDetailRowWidget(
                      icon: Icons.calendar_today,
                      label: 'Fecha',
                      value: _formatEntityDate(appointment),
                    ),
                    const SizedBox(height: 16),
                    AppointmentDetailRowWidget(
                      icon: Icons.access_time,
                      label: 'Hora',
                      value: appointment.time,
                    ),
                    if (appointment.paymentMethodName != null) ...[
                      const SizedBox(height: 16),
                      AppointmentDetailRowWidget(
                        icon: Icons.payment,
                        label: 'Método de Pago',
                        value: appointment.paymentMethodName!,
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: AppColors.primaryGold,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Estado',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        AppBadge(
                          text: statusConfig['label'] as String,
                          type: statusConfig['badgeType'] as BadgeType,
                          icon: statusConfig['icon'] as IconData?,
                        ),
                      ],
                    ),
                    if (appointment.notes != null &&
                        appointment.notes!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Divider(color: AppColors.borderGold),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGold.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.note,
                              color: AppColors.primaryGold,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Notas',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  appointment.notes!,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 300.ms, delay: 250.ms)
              .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: 250.ms),
    );
  }
}
