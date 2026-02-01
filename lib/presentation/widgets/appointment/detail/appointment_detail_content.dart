import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/appointment_entity.dart';
import '../../../../domain/entities/user_entity.dart';
import '../appointment_detail_header_widget.dart';
import '../appointment_profile_card_widget.dart';
import '../payment_proof_viewer_widget.dart';
import '../../barber/barber_location_card_widget.dart';
import 'appointment_info_section.dart';
import 'appointment_service_card.dart';
import 'appointment_contact_card.dart';
import 'appointment_actions_section.dart';

/// Widget que muestra el contenido principal de los detalles de una cita.
///
/// Organiza todas las secciones de información de la cita de forma estructurada.
class AppointmentDetailContent extends StatelessWidget {
  final AppointmentEntity appointment;
  final UserEntity? currentUser;

  const AppointmentDetailContent({
    super.key,
    required this.appointment,
    this.currentUser,
  });

  static const TextStyle _sectionTitleStyle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  bool get _isBarber =>
      currentUser != null &&
      currentUser!.barberId != null &&
      currentUser!.barberId!.isNotEmpty &&
      (appointment.barber == null ||
          appointment.barber!.id == currentUser!.barberId);

  @override
  Widget build(BuildContext context) {
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
              // Header
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
                        child:
                            AppointmentProfileCardWidget(
                                  appointment: appointment,
                                  isBarber: _isBarber,
                                )
                                .animate()
                                .fadeIn(duration: 300.ms, delay: 0.ms)
                                .slideY(
                                  begin: 0.1,
                                  end: 0,
                                  duration: 300.ms,
                                  delay: 0.ms,
                                ),
                      ),

                      const SizedBox(height: 16),

                      // Section Title
                      const Text(
                            'Información de la Cita',
                            style: _sectionTitleStyle,
                          )
                          .animate()
                          .fadeIn(duration: 300.ms, delay: 100.ms)
                          .slideY(
                            begin: 0.1,
                            end: 0,
                            duration: 300.ms,
                            delay: 100.ms,
                          ),

                      const SizedBox(height: 12),

                      // Appointment Info Section
                      AppointmentInfoSection(appointment: appointment),

                      // Service Card
                      if (appointment.serviceId != null)
                        AppointmentServiceCard(appointment: appointment),

                      // Contact Card
                      AppointmentContactCard(appointment: appointment),

                      // Location Section
                      if (appointment.barber?.location != null &&
                          appointment.barber!.location.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text('Ubicación', style: _sectionTitleStyle)
                            .animate()
                            .fadeIn(duration: 300.ms, delay: 450.ms)
                            .slideY(
                              begin: 0.1,
                              end: 0,
                              duration: 300.ms,
                              delay: 450.ms,
                            ),
                        const SizedBox(height: 12),
                        RepaintBoundary(
                          child:
                              BarberLocationCardWidget(
                                    location: appointment.barber!.location,
                                    latitude: appointment.barber!.latitude,
                                    longitude: appointment.barber!.longitude,
                                  )
                                  .animate()
                                  .fadeIn(duration: 300.ms, delay: 500.ms)
                                  .slideY(
                                    begin: 0.1,
                                    end: 0,
                                    duration: 300.ms,
                                    delay: 500.ms,
                                  ),
                        ),
                      ],

                      // Payment Proof Section
                      if (appointment.paymentProof != null &&
                          appointment.paymentProof!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                              'Comprobante de Pago',
                              style: _sectionTitleStyle,
                            )
                            .animate()
                            .fadeIn(duration: 300.ms, delay: 450.ms)
                            .slideY(
                              begin: 0.1,
                              end: 0,
                              duration: 300.ms,
                              delay: 450.ms,
                            ),
                        const SizedBox(height: 12),
                        RepaintBoundary(
                          child:
                              PaymentProofViewerWidget(
                                    imageUrl: appointment.paymentProof!,
                                  )
                                  .animate()
                                  .fadeIn(duration: 300.ms, delay: 500.ms)
                                  .slideY(
                                    begin: 0.1,
                                    end: 0,
                                    duration: 300.ms,
                                    delay: 500.ms,
                                  ),
                        ),
                      ],

                      // Actions Section
                      AppointmentActionsSection(
                        appointment: appointment,
                        currentUser: currentUser,
                      ),

                      const SizedBox(height: 16),
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
