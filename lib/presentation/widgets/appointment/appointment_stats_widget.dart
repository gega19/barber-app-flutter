import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/appointment_entity.dart';
import '../../cubit/appointment/appointment_cubit.dart';

/// Widget para mostrar las estadísticas de citas (Total, Próximas)
class AppointmentStatsWidget extends StatelessWidget {
  const AppointmentStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentCubit, AppointmentState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state is AppointmentLoaded) {
          final all = state.appointments;
          final upcoming = all
              .where(
                (a) =>
                    a.status == AppointmentStatus.pending ||
                    a.status == AppointmentStatus.upcoming,
              )
              .toList();
          return Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Total',
                  value: '${all.length}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Próximas',
                  value: '${upcoming.length}',
                ),
              ),
            ],
          );
        }
        // Skeleton durante la carga
        return Row(
          children: [
            Expanded(
              child: _StatCardSkeleton(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCardSkeleton(),
            ),
          ],
        );
      },
    );
  }
}

/// Widget para una tarjeta de estadística
class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryGold.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.borderGold,
        ),
      ),
      child: Text(
        '$value $label',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.primaryGold,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Skeleton para la tarjeta de estadística
class _StatCardSkeleton extends StatelessWidget {
  const _StatCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.borderGold,
        ),
      ),
      child: Container(
        height: 14,
        decoration: BoxDecoration(
          color: AppColors.primaryGold.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

