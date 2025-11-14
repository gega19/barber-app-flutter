import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/workplace_utils.dart';
import '../../../domain/entities/workplace_entity.dart';
import 'workplace_info_item_widget.dart';

/// Widget para el tab de información de la barbería
class WorkplaceInfoTabWidget extends StatelessWidget {
  final WorkplaceEntity workplace;

  const WorkplaceInfoTabWidget({
    super.key,
    required this.workplace,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información General',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .slideX(begin: -0.1, end: 0, duration: 300.ms),
            const SizedBox(height: 16),
            if (workplace.address != null)
              WorkplaceInfoItemWidget(
                icon: Icons.location_on,
                label: 'Dirección',
                value: workplace.address!,
              )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 100.ms)
                  .slideX(begin: -0.1, end: 0, duration: 300.ms, delay: 100.ms),
            if (workplace.city != null) ...[
              const SizedBox(height: 12),
              WorkplaceInfoItemWidget(
                icon: Icons.location_city,
                label: 'Ciudad',
                value: workplace.city!,
              )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 200.ms)
                  .slideX(begin: -0.1, end: 0, duration: 300.ms, delay: 200.ms),
            ],
            const SizedBox(height: 12),
            WorkplaceInfoItemWidget(
              icon: Icons.star,
              label: 'Calificación',
              value: WorkplaceUtils.formatRating(workplace),
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: 300.ms)
                .slideX(begin: -0.1, end: 0, duration: 300.ms, delay: 300.ms),
          ],
        ),
      ),
    );
  }
}

