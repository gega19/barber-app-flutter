import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../cubit/workplace/workplace_cubit.dart';
import '../common/loading_widget.dart';
import '../common/error_widget.dart';
import '../common/empty_state_widget.dart';
import '../common/refreshable_list.dart';
import '../workplace/workplace_card_widget.dart';
import '../../../domain/entities/workplace_entity.dart';

/// Contenido del tab de barberías
class WorkplacesTabContent extends StatelessWidget {
  final List<WorkplaceEntity> Function(List<WorkplaceEntity>) applyFilters;

  const WorkplacesTabContent({super.key, required this.applyFilters});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkplaceCubit, WorkplaceState>(
      builder: (context, state) {
        if (state is WorkplaceLoading) {
          return const LoadingListWidget();
        }

        if (state is WorkplaceError) {
          return AppErrorWidget(
            message: state.message,
            onRetry: () {
              context.read<WorkplaceCubit>().loadWorkplaces();
            },
          );
        }

        if (state is WorkplaceLoaded) {
          final filteredWorkplaces = applyFilters(state.workplaces);

          if (filteredWorkplaces.isEmpty) {
            return EmptyStateWidget(
              message: 'No se encontraron barberías',
              onRefresh: () {
                context.read<WorkplaceCubit>().loadWorkplaces();
              },
            );
          }

          return RefreshableList<WorkplaceEntity>(
            items: filteredWorkplaces,
            onRefresh: () async {
              context.read<WorkplaceCubit>().loadWorkplaces();
            },
            itemBuilder: (context, workplace, index) {
              return WorkplaceCardWidget(
                workplace: workplace,
                onTap: () {
                  context.push('/workplace/${workplace.id}');
                },
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
