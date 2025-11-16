import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/appointment_utils.dart';
import '../../../domain/entities/appointment_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../cubit/auth/auth_cubit.dart';
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
                      // Actions
                      if (appointment.status == AppointmentStatus.pending ||
                          appointment.status == AppointmentStatus.upcoming) ...[
                        AppButton(
                          text: 'Cancelar Cita',
                          onPressed: () {
                            // TODO: Implementar cancelación
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Funcionalidad de cancelación próximamente',
                                ),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          },
                          type: ButtonType.outline,
                        )
                            .animate()
                            .fadeIn(duration: 300.ms, delay: 500.ms)
                            .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: 500.ms),
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
