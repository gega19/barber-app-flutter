import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../cubit/barber/barber_cubit.dart';
import '../../cubit/workplace/workplace_cubit.dart';
import '../../../domain/entities/barber_entity.dart';
import '../../../domain/entities/workplace_entity.dart';

/// Fila de filtros con contador de resultados y botón de filtros
class HomeFiltersRow extends StatelessWidget {
  final int tabIndex;
  final String searchQuery;
  final String sortBy;
  final String sortOrder;
  final List<BarberEntity> Function(List<BarberEntity>) applyBarberFilters;
  final List<WorkplaceEntity> Function(List<WorkplaceEntity>)
  applyWorkplaceFilters;
  final VoidCallback onFiltersPressed;

  const HomeFiltersRow({
    super.key,
    required this.tabIndex,
    required this.searchQuery,
    required this.sortBy,
    required this.sortOrder,
    required this.applyBarberFilters,
    required this.applyWorkplaceFilters,
    required this.onFiltersPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: tabIndex == 0
              ? BlocBuilder<BarberCubit, BarberState>(
                  builder: (context, state) {
                    if (state is BarberLoaded) {
                      final filtered = applyBarberFilters(state.barbers);
                      final count = state.totalCount ?? filtered.length;
                      return Text(
                        '$count barberos encontrados',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                )
              : BlocBuilder<WorkplaceCubit, WorkplaceState>(
                  builder: (context, state) {
                    if (state is WorkplaceLoaded) {
                      final filtered = applyWorkplaceFilters(state.workplaces);
                      final count = state.totalCount ?? filtered.length;
                      return Text(
                        '$count barberías encontradas',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border, color: AppColors.primaryGold),
          onPressed: () {
            context.push('/favorites');
          },
          tooltip: 'Mis Favoritos',
        ),
        IconButton(
          icon: const Icon(Icons.emoji_events, color: AppColors.primaryGold),
          onPressed: () {
            context.push('/competition');
          },
          tooltip: 'Ranking',
        ),
        IconButton(
          icon: const Icon(Icons.tune, color: AppColors.primaryGold),
          onPressed: onFiltersPressed,
          tooltip: 'Filtros',
        ),
      ],
    );
  }
}
