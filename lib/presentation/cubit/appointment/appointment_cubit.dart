import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/appointment_entity.dart';
import '../../../domain/usecases/appointment/get_appointments_usecase.dart';
import '../../../domain/usecases/appointment/create_appointment_usecase.dart';
import '../../../domain/usecases/appointment/cancel_appointment_usecase.dart';
import '../../../domain/usecases/appointment/mark_as_attended_usecase.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/injection/injection.dart';

part 'appointment_state.dart';

class AppointmentCubit extends Cubit<AppointmentState> {
  final GetAppointmentsUseCase getAppointmentsUseCase;
  final CreateAppointmentUseCase createAppointmentUseCase;
  final CancelAppointmentUseCase cancelAppointmentUseCase;
  final MarkAsAttendedUseCase markAsAttendedUseCase;
  final AnalyticsService analyticsService = sl<AnalyticsService>();

  AppointmentCubit({
    required this.getAppointmentsUseCase,
    required this.createAppointmentUseCase,
    required this.cancelAppointmentUseCase,
    required this.markAsAttendedUseCase,
  }) : super(AppointmentInitial());

  Future<void> loadAppointments() async {
    if (isClosed) return;
    emit(AppointmentLoading());

    final result = await getAppointmentsUseCase();

    if (isClosed) return;
    
    result.fold(
      (failure) {
        if (!isClosed) emit(AppointmentError(failure.message));
      },
      (appointments) {
        if (!isClosed) emit(AppointmentLoaded(appointments));
      },
    );
  }

  Future<bool> createAppointment({
    required String barberId,
    String? serviceId,
    required DateTime date,
    required String time,
    required String paymentMethod,
    String? paymentProof,
    String? notes,
  }) async {
    if (isClosed) return false;
    emit(AppointmentCreating());

    final result = await createAppointmentUseCase(
      barberId: barberId,
      serviceId: serviceId,
      date: date,
      time: time,
      paymentMethod: paymentMethod,
      paymentProof: paymentProof,
      notes: notes,
    );

    if (isClosed) return false;

    return result.fold(
      (failure) {
        if (!isClosed) emit(AppointmentError(failure.message));
        return false;
      },
      (appointment) async {
        // Track analytics
        await analyticsService.trackEvent(
          eventName: 'appointment_created',
          eventType: 'user_action',
          properties: {
            'barberId': barberId,
            'serviceId': serviceId,
            'date': date.toIso8601String(),
            'time': time,
            'paymentMethod': paymentMethod,
          },
        );
        // Recargar citas después de crear una nueva
        if (!isClosed) {
          loadAppointments();
        }
        return true;
      },
    );
  }

  Future<bool> cancelAppointment(String appointmentId) async {
    if (isClosed) return false;
    emit(AppointmentCancelling());

    final result = await cancelAppointmentUseCase(appointmentId);

    if (isClosed) return false;

    return result.fold(
      (failure) {
        if (!isClosed) emit(AppointmentError(failure.message));
        return false;
      },
      (_) async {
        // Track analytics
        await analyticsService.trackEvent(
          eventName: 'appointment_cancelled',
          eventType: 'user_action',
          properties: {'appointmentId': appointmentId},
        );
        // Recargar citas después de cancelar
        if (!isClosed) {
          loadAppointments();
        }
        return true;
      },
    );
  }

  Future<bool> markAsAttended(String appointmentId) async {
    if (isClosed) return false;
    emit(AppointmentCompleting());

    final result = await markAsAttendedUseCase(appointmentId);

    if (isClosed) return false;

    return result.fold(
      (failure) {
        if (!isClosed) emit(AppointmentError(failure.message));
        return false;
      },
      (_) async {
        // Track analytics
        await analyticsService.trackEvent(
          eventName: 'appointment_completed',
          eventType: 'user_action',
          properties: {'appointmentId': appointmentId},
        );
        // Recargar citas después de completar
        if (!isClosed) {
          loadAppointments();
        }
        return true;
      },
    );
  }
}
