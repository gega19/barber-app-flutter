import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/service_model.dart';
import 'barber_service_card_widget.dart';
import 'barber_service_card_skeleton.dart';

/// Widget para mostrar la lista de servicios del barbero
class BarberServicesListWidget extends StatelessWidget {
  final List<ServiceModel> services;
  final bool loading;

  const BarberServicesListWidget({
    super.key,
    required this.services,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Servicios',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(3, (index) => const BarberServiceCardSkeleton()),
        ],
      );
    }

    if (services.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Servicios',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        )
            .animate()
            .fadeIn(duration: 300.ms)
            .slideX(begin: -0.1, end: 0, duration: 300.ms),
        const SizedBox(height: 12),
        ...services.asMap().entries.map((entry) {
          final index = entry.key;
          final service = entry.value;
          return RepaintBoundary(
            key: ValueKey('service_${service.id}'),
            child: BarberServiceCardWidget(service: service),
          )
              .animate()
              .fadeIn(duration: 300.ms, delay: Duration(milliseconds: index * 50))
              .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: Duration(milliseconds: index * 50));
        }),
      ],
    );
  }
}

