import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../cubit/barber/barber_cubit.dart';
import '../common/loading_widget.dart';
import '../common/error_widget.dart';
import '../common/empty_state_widget.dart';
import '../common/refreshable_list.dart';
import '../barber/barber_card_widget.dart';
import '../../../domain/entities/barber_entity.dart';

/// Contenido del tab de barberos
class BarbersTabContent extends StatelessWidget {
  final List<BarberEntity> Function(List<BarberEntity>) applyFilters;
  final void Function(int?)? onTotalCountChanged;

  const BarbersTabContent({
    super.key,
    required this.applyFilters,
    this.onTotalCountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BarberCubit, BarberState>(
      builder: (context, state) {
        if (state is BarberLoading) {
          return const LoadingListWidget();
        }

        if (state is BarberError) {
          return AppErrorWidget(
            message: state.message,
            onRetry: () {
              context.read<BarberCubit>().loadBarbers(reset: true);
            },
          );
        }

        if (state is BarberLoaded) {
          // Notify parent of total count
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onTotalCountChanged?.call(state.totalCount);
          });

          final filteredBarbers = applyFilters(state.barbers);

          if (filteredBarbers.isEmpty) {
            return EmptyStateWidget(
              message: 'No se encontraron barberos',
              icon: Icons.content_cut_rounded,
              onRefresh: () {
                context.read<BarberCubit>().loadBarbers(reset: true);
              },
            );
          }

          return RefreshableList<BarberEntity>(
            items: filteredBarbers,
            onRefresh: () async {
              context.read<BarberCubit>().loadBarbers(reset: true);
            },
            onLoadMore: () {
              context.read<BarberCubit>().loadMoreBarbers();
            },
            itemBuilder: (context, barber, index) {
              return BarberCardWidget(
                barber: barber,
                onTap: () {
                  context.push('/barber/${barber.id}');
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
