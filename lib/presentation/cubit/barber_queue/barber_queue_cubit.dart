import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/appointment_repository.dart';
import '../../../domain/entities/appointment_entity.dart';
import '../../../core/errors/failures.dart';
import 'barber_queue_state.dart';

class BarberQueueCubit extends Cubit<BarberQueueState> {
  final AppointmentRepository appointmentRepository;

  BarberQueueCubit(this.appointmentRepository) : super(BarberQueueInitial());

  Future<void> loadBarberQueue(String barberId, {DateTime? date}) async {
    emit(BarberQueueLoading());
    
    final result = await appointmentRepository.getBarberQueue(barberId, date: date);
    
    result.fold(
      (failure) {
        String message = 'Error al cargar la cola';
        if (failure is ServerFailure) {
          message = failure.message;
        } else if (failure is NetworkFailure) {
          message = failure.message;
        }
        emit(BarberQueueError(message));
      },
      (appointments) {
        // Filtrar citas COMPLETED - no mostrarlas en la cola del día (ya fueron atendidas)
        final filteredAppointments = appointments.where((apt) {
          return apt.status != AppointmentStatus.completed;
        }).toList();
        
        emit(BarberQueueLoaded(filteredAppointments));
      },
    );
  }

  Future<void> cancelAppointment(String appointmentId, String barberId) async {
    final result = await appointmentRepository.cancelAppointment(appointmentId);
    
    result.fold(
      (failure) {
        String message = 'Error al cancelar la cita';
        if (failure is ServerFailure) {
          message = failure.message;
        } else if (failure is NetworkFailure) {
          message = failure.message;
        }
        emit(BarberQueueError(message));
      },
      (_) {
        // Recargar la cola después de cancelar
        loadBarberQueue(barberId);
      },
    );
  }

  Future<void> markAsAttended(String appointmentId, String barberId) async {
    final result = await appointmentRepository.markAsAttended(appointmentId);
    
    result.fold(
      (failure) {
        String message = 'Error al marcar la cita como atendida';
        if (failure is ServerFailure) {
          message = failure.message;
        } else if (failure is NetworkFailure) {
          message = failure.message;
        }
        emit(BarberQueueError(message));
      },
      (_) {
        // Recargar la cola después de marcar como atendida
        loadBarberQueue(barberId);
      },
    );
  }

  void reset() {
    emit(BarberQueueInitial());
  }
}

