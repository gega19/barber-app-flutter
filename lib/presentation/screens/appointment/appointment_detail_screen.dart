import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/appointment_utils.dart';
import '../../../domain/entities/appointment_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../../cubit/appointment/appointment_cubit.dart';
import '../../widgets/appointment/appointment_detail_header_widget.dart';
import '../../widgets/appointment/appointment_profile_card_widget.dart';
import '../../widgets/appointment/appointment_detail_row_widget.dart';
import '../../widgets/appointment/payment_status_widget.dart';
import '../../widgets/appointment/payment_proof_viewer_widget.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_button.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final AppointmentEntity appointment;

  const AppointmentDetailScreen({super.key, required this.appointment});

  UserEntity? _getCurrentUser(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      return authState.user;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = _getCurrentUser(context);
    // Determinar si el usuario actual es el barbero de esta cita específica
    // Comparar barberId del usuario con el id del barbero de la cita
    final bool isBarber = user != null && 
        appointment.barber != null && 
        user.barberId != null && 
        user.barberId == appointment.barber!.id;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppointmentDetailHeaderWidget(appointment: appointment)
                  .animate()
                  .fadeIn(duration: 200.ms)
                  .slideY(begin: -0.1, end: 0, duration: 200.ms),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Card
                      RepaintBoundary(
                        child: AppointmentProfileCardWidget(
                          appointment: appointment,
                          isBarber: isBarber,
                        )
                            .animate()
                            .fadeIn(duration: 300.ms, delay: 0.ms)
                            .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: 0.ms),
                      ),
                      const SizedBox(height: 16),
                      // Appointment Details
                      const Text(
                        'Información de la Cita',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 300.ms, delay: 100.ms)
                          .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: 100.ms),
                      const SizedBox(height: 12),
                      RepaintBoundary(
                        child: AppCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            AppointmentDetailRowWidget(
                              icon: Icons.calendar_today,
                              label: 'Fecha',
                              value: AppointmentUtils.formatAppointmentDate(
                                appointment.date,
                              ),
                            ),
                            Divider(color: AppColors.borderGold),
                            AppointmentDetailRowWidget(
                              icon: Icons.access_time,
                              label: 'Hora',
                              value: appointment.time,
                            ),
                            if (appointment.paymentMethod != null) ...[
                              Divider(color: AppColors.borderGold),
                              AppointmentDetailRowWidget(
                                icon: Icons.payment,
                                label: 'Método de Pago',
                                value: appointment.paymentMethodName ??
                                    AppointmentUtils.getPaymentMethodLabel(
                                      appointment.paymentMethod!,
                                    ),
                              ),
                            ],
                            if (appointment.paymentStatus != null) ...[
                              Divider(color: AppColors.borderGold),
                              PaymentStatusWidget(appointment: appointment),
                            ],
                            if (appointment.notes != null &&
                                appointment.notes!.isNotEmpty) ...[
                              Divider(color: AppColors.borderGold),
                              AppointmentDetailRowWidget(
                                icon: Icons.note,
                                label: 'Notas',
                                value: appointment.notes!,
                                isMultiline: true,
                              ),
                            ],
                          ],
                        ),
                        )
                            .animate()
                            .fadeIn(duration: 300.ms, delay: 200.ms)
                            .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: 200.ms),
                      ),
                      if (appointment.serviceId != null) ...[
                        const SizedBox(height: 16),
                        RepaintBoundary(
                          child: AppCard(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.cut,
                                    color: AppColors.primaryGold,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Servicio',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // TODO: Agregar información del servicio cuando esté disponible en la entidad
                              Text(
                                'ID: ${appointment.serviceId ?? 'N/A'}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          )
                              .animate()
                              .fadeIn(duration: 300.ms, delay: 300.ms)
                              .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: 300.ms),
                        ),
                      ],
                      // Payment Proof Section
                      if (appointment.paymentProof != null &&
                          appointment.paymentProof!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Comprobante de Pago',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 300.ms, delay: 400.ms)
                            .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: 400.ms),
                        const SizedBox(height: 12),
                        RepaintBoundary(
                          child: AppCard(
                            padding: const EdgeInsets.all(20),
                            child: PaymentProofViewerWidget(
                              imageUrl: appointment.paymentProof!,
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 300.ms, delay: 450.ms)
                              .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: 450.ms),
                        ),
                      ],
                      const SizedBox(height: 24),
                      // Actions for Barbers
                      if (isBarber &&
                          appointment.status != AppointmentStatus.completed &&
                          appointment.status != AppointmentStatus.cancelled) ...[
                        BlocConsumer<AppointmentCubit, AppointmentState>(
                          listener: (context, state) {
                            if (state is AppointmentError) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(state.message),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            } else if (state is AppointmentLoaded) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Acción realizada exitosamente'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          },
                          builder: (context, state) {
                            final isCompleting = state is AppointmentCompleting;
                            final isCancelling = state is AppointmentCancelling;
                            
                            return Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: isCompleting || isCancelling
                                        ? null
                                        : () async {
                                            final confirmed = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                backgroundColor: AppColors.backgroundCard,
                                                title: const Text(
                                                  'Completar Cita',
                                                  style: TextStyle(
                                                    color: AppColors.textPrimary,
                                                  ),
                                                ),
                                                content: const Text(
                                                  '¿Estás seguro de que deseas marcar esta cita como completada?',
                                                  style: TextStyle(
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context).pop(false),
                                                    child: const Text(
                                                      'Cancelar',
                                                      style: TextStyle(
                                                        color: AppColors.textSecondary,
                                                      ),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context).pop(true),
                                                    child: const Text(
                                                      'Completar',
                                                      style: TextStyle(
                                                        color: AppColors.success,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );

                                            if (confirmed == true && context.mounted) {
                                              await context
                                                  .read<AppointmentCubit>()
                                                  .markAsAttended(appointment.id);
                                            }
                                          },
                                    icon: isCompleting
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Icon(Icons.check_circle, size: 20),
                                    label: Text(
                                      isCompleting ? 'Completando...' : 'Completar',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.success,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  )
                                      .animate()
                                      .fadeIn(duration: 300.ms, delay: 500.ms)
                                      .slideY(
                                          begin: 0.1,
                                          end: 0,
                                          duration: 300.ms,
                                          delay: 500.ms),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: isCompleting || isCancelling
                                        ? null
                                        : () async {
                                            final confirmed = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                backgroundColor: AppColors.backgroundCard,
                                                title: const Text(
                                                  'Cancelar Cita',
                                                  style: TextStyle(
                                                    color: AppColors.textPrimary,
                                                  ),
                                                ),
                                                content: const Text(
                                                  '¿Estás seguro de que deseas cancelar esta cita? El cliente será notificado.',
                                                  style: TextStyle(
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context).pop(false),
                                                    child: const Text(
                                                      'No',
                                                      style: TextStyle(
                                                        color: AppColors.textSecondary,
                                                      ),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context).pop(true),
                                                    child: const Text(
                                                      'Sí, Cancelar',
                                                      style: TextStyle(
                                                        color: AppColors.error,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );

                                            if (confirmed == true && context.mounted) {
                                              final success = await context
                                                  .read<AppointmentCubit>()
                                                  .cancelAppointment(appointment.id);
                                              
                                              if (success && context.mounted) {
                                                Navigator.of(context).pop();
                                              }
                                            }
                                          },
                                    icon: isCancelling
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Icon(Icons.cancel, size: 20),
                                    label: Text(
                                      isCancelling ? 'Cancelando...' : 'Cancelar',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.error,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  )
                                      .animate()
                                      .fadeIn(duration: 300.ms, delay: 550.ms)
                                      .slideY(
                                          begin: 0.1,
                                          end: 0,
                                          duration: 300.ms,
                                          delay: 550.ms),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                      // Actions for Clients
                      if (!isBarber &&
                          (appointment.status == AppointmentStatus.pending ||
                              appointment.status == AppointmentStatus.upcoming)) ...[
                        BlocConsumer<AppointmentCubit, AppointmentState>(
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
                            
                            return AppButton(
                              text: isCancelling ? 'Cancelando...' : 'Cancelar Cita',
                              onPressed: isCancelling
                                  ? null
                                  : () async {
                                      // Mostrar diálogo de confirmación
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          backgroundColor: AppColors.backgroundCard,
                                          title: const Text(
                                            'Cancelar Cita',
                                            style: TextStyle(
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          content: const Text(
                                            '¿Estás seguro de que deseas cancelar esta cita? Esta acción no se puede deshacer.',
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(false),
                                              child: const Text(
                                                'No',
                                                style: TextStyle(
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(true),
                                              child: const Text(
                                                'Sí, Cancelar',
                                                style: TextStyle(
                                                  color: AppColors.error,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirmed == true) {
                                        final success = await context
                                            .read<AppointmentCubit>()
                                            .cancelAppointment(appointment.id);
                                        
                                        if (success && context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Cita cancelada exitosamente'),
                                              backgroundColor: AppColors.success,
                                            ),
                                          );
                                          Navigator.of(context).pop();
                                        }
                                      }
                                    },
                              type: ButtonType.outline,
                            )
                                .animate()
                                .fadeIn(duration: 300.ms, delay: 500.ms)
                                .slideY(
                                    begin: 0.1,
                                    end: 0,
                                    duration: 300.ms,
                                    delay: 500.ms);
                          },
                        ),
                      ],
                      if (appointment.status == AppointmentStatus.completed &&
                          appointment.rating == null) ...[
                        AppButton(
                          text: 'Calificar Cita',
                          onPressed: () {
                            // TODO: Implementar calificación
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Funcionalidad de calificación próximamente',
                                ),
                                backgroundColor: AppColors.primaryGold,
                              ),
                            );
                          },
                        )
                            .animate()
                            .fadeIn(duration: 300.ms, delay: 500.ms)
                            .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: 500.ms),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
