import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/appointment_entity.dart';
import '../../../domain/usecases/appointment/get_appointments_usecase.dart';
import '../../../domain/usecases/appointment/create_appointment_usecase.dart';

part 'appointment_state.dart';

class AppointmentCubit extends Cubit<AppointmentState> {
  final GetAppointmentsUseCase getAppointmentsUseCase;
  final CreateAppointmentUseCase createAppointmentUseCase;

  AppointmentCubit({
    required this.getAppointmentsUseCase,
    required this.createAppointmentUseCase,
  }) : super(AppointmentInitial());

  Future<void> loadAppointments() async {
    emit(AppointmentLoading());

    final result = await getAppointmentsUseCase();

    result.fold(
      (failure) => emit(AppointmentError(failure.message)),
      (appointments) => emit(AppointmentLoaded(appointments)),
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

    return result.fold(
      (failure) {
        emit(AppointmentError(failure.message));
        return false;
      },
      (appointment) {
        // Recargar citas después de crear una nueva
        loadAppointments();
        return true;
      },
    );
  }
}
