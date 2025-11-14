import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/barber_entity.dart';
import 'workplace_barber_card_widget.dart';
import 'workplace_barber_card_skeleton.dart';

/// Widget para mostrar la lista de barberos de la barbería
class WorkplaceBarbersListWidget extends StatelessWidget {
  final List<BarberEntity> barbers;
  final bool loading;

  const WorkplaceBarbersListWidget({
    super.key,
    required this.barbers,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return const WorkplaceBarberCardSkeleton();
        },
      );
    }

    if (barbers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .scale(delay: 200.ms, duration: 300.ms),
            const SizedBox(height: 16),
            Text(
              'No hay barberos disponibles',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms, delay: 300.ms)
                .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: 300.ms),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: barbers.length,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      addSemanticIndexes: false,
      itemBuilder: (context, index) {
        final barber = barbers[index];
        return WorkplaceBarberCardWidget(
          key: ValueKey('workplace_barber_${barber.id}'),
          barber: barber,
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: Duration(milliseconds: index * 100))
            .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: Duration(milliseconds: index * 100));
      },
    );
  }
}

