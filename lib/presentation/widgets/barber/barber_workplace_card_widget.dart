import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/workplace_model.dart';
import '../../../core/utils/barber_utils.dart';
import '../common/app_card.dart';

/// Widget para mostrar la tarjeta de barbería del barbero
class BarberWorkplaceCardWidget extends StatelessWidget {
  final WorkplaceModel? workplace;
  final String? serviceType;

  const BarberWorkplaceCardWidget({
    super.key,
    this.workplace,
    this.serviceType,
  });

  @override
  Widget build(BuildContext context) {
    if (workplace == null && serviceType == null) {
      return const SizedBox.shrink();
    }

    return RepaintBoundary(
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (workplace != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.store,
                    color: AppColors.primaryGold,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Barbería',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          workplace!.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (workplace!.address != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            workplace!.address!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (serviceType != null) const SizedBox(height: 16),
            ],
            if (serviceType != null)
              Row(
                children: [
                  const Icon(
                    Icons.build_circle_outlined,
                    color: AppColors.primaryGold,
                    size: 20,
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
          ],
        ),
      ),
    );
  }
}
