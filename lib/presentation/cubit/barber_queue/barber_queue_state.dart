import 'package:equatable/equatable.dart';
import '../../../domain/entities/appointment_entity.dart';

abstract class BarberQueueState extends Equatable {
  const BarberQueueState();

  @override
  List<Object?> get props => [];
}

class BarberQueueInitial extends BarberQueueState {}

class BarberQueueLoading extends BarberQueueState {}

class BarberQueueLoaded extends BarberQueueState {
  final List<AppointmentEntity> appointments;

  const BarberQueueLoaded(this.appointments);

  @override
  List<Object?> get props => [appointments];
}

class BarberQueueError extends BarberQueueState {
  final String message;

  const BarberQueueError(this.message);

  @override
  List<Object?> get props => [message];
}

