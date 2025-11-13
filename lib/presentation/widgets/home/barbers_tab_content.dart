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

  const BarbersTabContent({super.key, required this.applyFilters});

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
              context.read<BarberCubit>().loadBestBarbers();
            },
          );
        }

        if (state is BarberLoaded) {
          final filteredBarbers = applyFilters(state.barbers);

          if (filteredBarbers.isEmpty) {
            return EmptyStateWidget(
              message: 'No se encontraron barberos',
              onRefresh: () {
                context.read<BarberCubit>().loadBestBarbers();
              },
            );
          }

          return RefreshableList<BarberEntity>(
            items: filteredBarbers,
            onRefresh: () async {
              context.read<BarberCubit>().loadBestBarbers();
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
