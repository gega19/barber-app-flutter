import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/service_model.dart';
import '../../../data/models/promotion_model.dart';
import 'promotion_banner_widget.dart';
import 'service_card_widget.dart';
import 'service_card_skeleton.dart';

/// Widget para el paso de selección de servicio
class ServiceSelectionStep extends StatelessWidget {
  final List<ServiceModel> services;
  final bool loadingServices;
  final String? selectedServiceId;
  final PromotionModel? activePromotion;
  final ValueChanged<String?> onServiceSelected;

  const ServiceSelectionStep({
    super.key,
    required this.services,
    required this.loadingServices,
    required this.selectedServiceId,
    this.activePromotion,
    required this.onServiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (loadingServices) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selecciona un servicio',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Elige el servicio que deseas reservar',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ...List.generate(3, (index) => const ServiceCardSkeleton()),
        ],
      );
    }

    if (services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cut_outlined,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .scale(delay: 200.ms, duration: 300.ms),
            const SizedBox(height: 16),
            Text(
              'No hay servicios disponibles',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            )
                .animate()
                .fadeIn(duration: 500.ms, delay: 300.ms)
                .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: 300.ms),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecciona un servicio',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Elige el servicio que deseas reservar',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 24),
        // Mostrar promoción activa si existe
        if (activePromotion != null) ...[
          PromotionBannerWidget(promotion: activePromotion!),
          const SizedBox(height: 16),
        ],
        ...services.asMap().entries.map((entry) {
          final index = entry.key;
          final service = entry.value;
          return RepaintBoundary(
            key: ValueKey('service_${service.id}'),
            child: ServiceCardWidget(
              service: service,
              isSelected: selectedServiceId == service.id,
              activePromotion: activePromotion,
              onTap: () => onServiceSelected(service.id),
            ),
          )
              .animate()
              .fadeIn(duration: 300.ms, delay: Duration(milliseconds: index * 50))
              .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: Duration(milliseconds: index * 50));
        }),
      ],
    );
  }
}
