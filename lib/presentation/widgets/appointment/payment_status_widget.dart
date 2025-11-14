import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/appointment_entity.dart';

/// Widget para mostrar el estado del pago en el detalle de cita
class PaymentStatusWidget extends StatelessWidget {
  final AppointmentEntity appointment;

  const PaymentStatusWidget({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    final status = appointment.paymentStatus?.toUpperCase() ?? 'PENDING';
    String label;
    Color color;
    IconData icon;

    switch (status) {
      case 'PENDING':
        label = 'Pendiente de Verificación';
        color = AppColors.primaryGold;
        icon = Icons.pending;
        break;
      case 'VERIFIED':
        label = 'Pago Verificado';
        color = AppColors.success;
        icon = Icons.check_circle;
        break;
      case 'REJECTED':
        label = 'Pago Rechazado';
        color = AppColors.error;
        icon = Icons.cancel;
        break;
      default:
        label = 'Estado Desconocido';
        color = AppColors.textSecondary;
        icon = Icons.help_outline;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estado del Pago',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: color, width: 1),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

