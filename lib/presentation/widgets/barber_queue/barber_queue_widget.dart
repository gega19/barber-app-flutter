import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/injection/injection.dart';
import '../../../domain/entities/appointment_entity.dart';
import '../../cubit/barber_queue/barber_queue_cubit.dart';
import '../../cubit/barber_queue/barber_queue_state.dart';
import '../common/app_avatar.dart';

/// Widget flotante para mostrar la cola del día del barbero
/// Se muestra como un FloatingActionButton con badge de cantidad
class BarberQueueFAB extends StatelessWidget {
  final String barberId;
  final int? initialCount;
  final VoidCallback? onTap;

  const BarberQueueFAB({
    super.key,
    required this.barberId,
    this.initialCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<BarberQueueCubit>(),
      child: BlocBuilder<BarberQueueCubit, BarberQueueState>(
        builder: (context, state) {
          int count = initialCount ?? 0;
          if (state is BarberQueueLoaded) {
            count = state.appointments.length;
          }

          return FloatingActionButton(
            onPressed: () => _showQueueDialog(context),
            backgroundColor: AppColors.primaryGold,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
          const Icon(
            Icons.content_cut,
            color: AppColors.textDark,
            size: 28,
          ),
                // Badge con el número de citas
                if (count > 0)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.textDark, width: 2),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showQueueDialog(BuildContext context) {
    final cubit = context.read<BarberQueueCubit>();
    // Cargar la cola cuando se abre el modal
    cubit.loadBarberQueue(barberId);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BlocProvider.value(
        value: cubit,
        child: _QueueBottomSheet(barberId: barberId, onItemTap: onTap),
      ),
    );
  }
}

/// Bottom sheet que muestra la lista de la cola
class _QueueBottomSheet extends StatelessWidget {
  final String barberId;
  final VoidCallback? onItemTap;

  const _QueueBottomSheet({required this.barberId, this.onItemTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return BlocBuilder<BarberQueueCubit, BarberQueueState>(
            builder: (context, state) {
              if (state is BarberQueueLoading) {
                return const Column(
                  children: [
                    SizedBox(height: 20),
                    CircularProgressIndicator(color: AppColors.primaryGold),
                    SizedBox(height: 20),
                    Text(
                      'Cargando cola...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              }

              if (state is BarberQueueError) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<BarberQueueCubit>().loadBarberQueue(
                          barberId,
                        );
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                );
              }

              if (state is BarberQueueLoaded) {
                final appointments = state.appointments;

                if (appointments.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.event_busy,
                        color: AppColors.textSecondary,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No hay citas para hoy',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tu cola está vacía',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    // Handle
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.content_cut,
                            color: AppColors.primaryGold,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Cola del día',
                            style: TextStyle(
                              color: AppColors.primaryGold,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGold.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${appointments.length}',
                              style: const TextStyle(
                                color: AppColors.primaryGold,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Lista de avatares
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: appointments.length,
                        itemBuilder: (context, index) {
                          final appointment = appointments[index];
                          return _QueueAvatarItem(
                            appointment: appointment,
                            barberId: barberId,
                            onTap: onItemTap,
                          );
                        },
                      ),
                    ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}

/// Widget individual para cada item de la cola
class _QueueAvatarItem extends StatelessWidget {
  final AppointmentEntity appointment;
  final String barberId;
  final VoidCallback? onTap;

  const _QueueAvatarItem({
    required this.appointment,
    required this.barberId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final client = appointment.client;
    final name = client?.name ?? 'Cliente';
    final avatar = client?.avatar;
    final avatarSeed = client?.avatarSeed;
    final time = appointment.time;
    final status = appointment.status.toString().split('.').last;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.backgroundCardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGold, width: 1.5),
        ),
        child: Row(
          children: [
            // Avatar usando AppAvatar para manejar el seed correctamente
            AppAvatar(
              imageUrl: avatar,
              name: name,
              avatarSeed: avatarSeed,
              size: 60,
              borderColor: AppColors.primaryGold,
            ),
            const SizedBox(width: 16),
            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: AppColors.textSecondary,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            time,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Indicador de estado y botón de cancelar
            Column(
              children: [
                // Solo mostrar el indicador de estado si NO es PENDING
                if (status.toUpperCase() != 'PENDING')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusText(status),
                      style: TextStyle(
                        color: _getStatusColor(status),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                // Botones de acción (solo si no está cancelada o completada)
                if (status.toUpperCase() != 'CANCELLED' &&
                    status.toUpperCase() != 'COMPLETED')
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Botón de Atendido
                        InkWell(
                          onTap: () => _showAttendedDialog(context),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.green.withValues(alpha: 0.5),
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Atendido',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Botón de Cancelar
                        InkWell(
                          onTap: () => _showCancelDialog(context),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.5),
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.cancel_outlined,
                                  color: Colors.red,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Cancelar',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAttendedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'Marcar como atendido',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          '¿Marcar esta cita como atendida? Se eliminará de la cola del día.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'No',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<BarberQueueCubit>().markAsAttended(
                appointment.id,
                barberId,
              );
            },
            child: const Text(
              'Sí, marcar',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'Cancelar cita',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          '¿Estás seguro de que deseas cancelar esta cita? Esta acción no se puede deshacer.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'No',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<BarberQueueCubit>().cancelAppointment(
                appointment.id,
                barberId,
              );
            },
            child: const Text(
              'Sí, cancelar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'UPCOMING':
      case 'CONFIRMED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'CANCELLED':
        return Colors.red;
      case 'COMPLETED':
        return Colors.blue;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'UPCOMING':
        return 'Próxima';
      case 'CONFIRMED':
        return 'Confirmada';
      case 'PENDING':
        return 'Pendiente';
      case 'CANCELLED':
        return 'Cancelada';
      case 'COMPLETED':
        return 'Completada';
      default:
        return status;
    }
  }
}
