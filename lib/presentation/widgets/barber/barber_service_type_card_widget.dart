import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/barber_utils.dart';
import '../common/app_card.dart';

/// Widget para mostrar solo el tipo de servicio del barbero
class BarberServiceTypeCardWidget extends StatelessWidget {
  final String? serviceType;

  const BarberServiceTypeCardWidget({
    super.key,
    this.serviceType,
  });

  @override
  Widget build(BuildContext context) {
    if (serviceType == null) {
      return const SizedBox.shrink();
    }

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(
            Icons.build_circle_outlined,
            color: AppColors.primaryGold,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tipo de Servicio',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  BarberUtils.getServiceTypeLabel(serviceType),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

