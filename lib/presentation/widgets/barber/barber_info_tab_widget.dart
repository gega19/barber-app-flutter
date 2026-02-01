import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/barber_entity.dart';
import 'package:flutter/services.dart';
import 'barber_info_item_widget.dart';

/// Widget para el tab de información del barbero
class BarberInfoTabWidget extends StatelessWidget {
  final BarberEntity barber;

  const BarberInfoTabWidget({super.key, required this.barber});

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
            BarberInfoItemWidget(
                  icon: Icons.location_on,
                  label: 'Ubicación',
                  value: barber.location,
                )
                .animate()
                .fadeIn(duration: 300.ms, delay: 100.ms)
                .slideX(begin: -0.1, end: 0, duration: 300.ms, delay: 100.ms),
            if (barber.phone != null && barber.phone!.isNotEmpty) ...[
              const SizedBox(height: 12),
              GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: barber.phone!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Teléfono copiado al portapapeles'),
                          backgroundColor: AppColors.primaryGold,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: BarberInfoItemWidget(
                            icon: Icons.phone,
                            label: 'Teléfono',
                            value: barber.phone!,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.copy,
                            color: AppColors.primaryGold,
                            size: 20,
                          ),
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: barber.phone!),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Teléfono copiado al portapapeles',
                                ),
                                backgroundColor: AppColors.primaryGold,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 150.ms)
                  .slideX(begin: -0.1, end: 0, duration: 300.ms, delay: 150.ms),
            ],
            const SizedBox(height: 12),
            BarberInfoItemWidget(
                  icon: Icons.work_outline,
                  label: 'Experiencia',
                  value: '${barber.experience} años',
                )
                .animate()
                .fadeIn(duration: 300.ms, delay: 200.ms)
                .slideX(begin: -0.1, end: 0, duration: 300.ms, delay: 200.ms),
            const SizedBox(height: 12),
            BarberInfoItemWidget(
                  icon: Icons.category,
                  label: 'Especialidad',
                  value: barber.specialty,
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
