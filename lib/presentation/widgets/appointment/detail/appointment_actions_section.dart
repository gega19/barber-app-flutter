import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/appointment_entity.dart';
import '../../../../domain/entities/user_entity.dart';
import '../../../cubit/appointment/appointment_cubit.dart';
import '../../common/app_button.dart';

/// Widget que muestra las acciones disponibles para una cita.
///
/// Las acciones varían dependiendo del rol del usuario (barbero/cliente)
/// y del estado de la cita.
class AppointmentActionsSection extends StatelessWidget {
  final AppointmentEntity appointment;
  final UserEntity? currentUser;

  const AppointmentActionsSection({
    super.key,
    required this.appointment,
    this.currentUser,
  });

  bool get _isBarber =>
      currentUser != null &&
      currentUser!.barberId != null &&
      currentUser!.barberId!.isNotEmpty;

  bool get _canCancel =>
      appointment.status == AppointmentStatus.pending ||
      appointment.status == AppointmentStatus.upcoming;

  bool get _canMarkAttended =>
      _isBarber && appointment.status == AppointmentStatus.pending;

  bool get _canRate =>
      !_isBarber &&
      appointment.status == AppointmentStatus.completed &&
      appointment.rating == null;

  Future<void> _handleCancel(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'Cancelar Cita',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          '¿Estás seguro de que deseas cancelar esta cita? Esta acción no se puede deshacer.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'No',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Sí, Cancelar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await context.read<AppointmentCubit>().cancelAppointment(
        appointment.id,
      );

      if (success && context.mounted) {
        if (_isBarber) {
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cita cancelada exitosamente'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop();
        }
      }
    }
  }

  Future<void> _handleMarkAttended(BuildContext context) async {
    final success = await context.read<AppointmentCubit>().markAsAttended(
      appointment.id,
    );

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cita marcada como atendida'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _handleRate(BuildContext context) {
    // TODO: Implementar calificación
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de calificación próximamente'),
        backgroundColor: AppColors.primaryGold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppointmentCubit, AppointmentState>(
      listener: (context, state) {
        if (state is AppointmentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isCancelling = state is AppointmentCancelling;
        final isMarkingAttended = state is AppointmentCompleting;

        final barberHasBothActions =
            _canMarkAttended && _isBarber && _canCancel;

        return Column(
          children: [
            // Acciones para barberos: Marcar como atendida y Cancelar (uno al lado del otro)
            if (barberHasBothActions) ...[
              const SizedBox(height: 16),
              Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Marcar como Atendida',
                          onPressed: isMarkingAttended
                              ? null
                              : () => _handleMarkAttended(context),
                          isLoading: isMarkingAttended,
                          icon: Icons.check_circle_outline,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          text: 'Cancelar',
                          onPressed: isCancelling
                              ? null
                              : () => _handleCancel(context),
                          type: ButtonType.outline,
                          isLoading: isCancelling,
                          icon: Icons.cancel_outlined,
                        ),
                      ),
                    ],
                  )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 500.ms)
                  .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: 500.ms),
            ] else if (_canMarkAttended) ...[
              // Solo marcar como atendida
              const SizedBox(height: 16),
              AppButton(
                    text: 'Marcar como Atendida',
                    onPressed: isMarkingAttended
                        ? null
                        : () => _handleMarkAttended(context),
                    isLoading: isMarkingAttended,
                    icon: Icons.check_circle_outline,
                  )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 500.ms)
                  .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: 500.ms),
            ] else if (_isBarber && _canCancel) ...[
              // Solo cancelar (barbero)
              const SizedBox(height: 16),
              AppButton(
                    text: 'Cancelar',
                    onPressed: isCancelling
                        ? null
                        : () => _handleCancel(context),
                    type: ButtonType.outline,
                    isLoading: isCancelling,
                    icon: Icons.cancel_outlined,
                  )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 500.ms)
                  .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: 500.ms),
            ],

            // Acción para clientes: Cancelar
            if (!_isBarber && _canCancel) ...[
              const SizedBox(height: 16),
              AppButton(
                    text: isCancelling ? 'Cancelando...' : 'Cancelar Cita',
                    onPressed: isCancelling
                        ? null
                        : () => _handleCancel(context),
                    type: ButtonType.outline,
                  )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 500.ms)
                  .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: 500.ms),
            ],

            // Acción para calificar
            if (_canRate) ...[
              const SizedBox(height: 16),
              AppButton(
                    text: 'Calificar Cita',
                    onPressed: () => _handleRate(context),
                  )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 500.ms)
                  .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: 500.ms),
            ],
          ],
        );
      },
    );
  }
}
