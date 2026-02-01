import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/user_entity.dart';
import '../../cubit/appointment/appointment_cubit.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../../widgets/appointment/detail/appointment_detail_loading.dart';
import '../../widgets/appointment/detail/appointment_detail_error.dart';
import '../../widgets/appointment/detail/appointment_detail_content.dart';

/// Pantalla de detalles de una cita.
///
/// Muestra toda la información relacionada con una cita específica,
/// incluyendo datos del barbero/cliente, servicio, ubicación y acciones disponibles.
class AppointmentDetailScreen extends StatefulWidget {
  final String appointmentId;

  const AppointmentDetailScreen({super.key, required this.appointmentId});

  @override
  State<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load appointment details when screen is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentCubit>().loadAppointment(widget.appointmentId);
    });
  }

  UserEntity? _getCurrentUser(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      return authState.user;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentCubit, AppointmentState>(
      builder: (context, appointmentState) {
        // Loading state
        if (appointmentState is AppointmentLoading ||
            appointmentState is AppointmentInitial) {
          return const AppointmentDetailLoading();
        }

        // Error state
        if (appointmentState is AppointmentError) {
          return AppointmentDetailError(message: appointmentState.message);
        }

        // Empty state
        if (appointmentState is AppointmentLoaded &&
            appointmentState.appointments.isEmpty) {
          return const AppointmentDetailError(message: 'Cita no encontrada');
        }

        // Loaded state - render appointment details
        final appointment =
            (appointmentState as AppointmentLoaded).appointments.first;
        final currentUser = _getCurrentUser(context);

        return AppointmentDetailContent(
          appointment: appointment,
          currentUser: currentUser,
        );
      },
    );
  }
}
