part of 'barber_availability_cubit.dart';

abstract class BarberAvailabilityState extends Equatable {
  const BarberAvailabilityState();

  @override
  List<Object> get props => [];
}

class BarberAvailabilityInitial extends BarberAvailabilityState {}

class BarberAvailabilityLoading extends BarberAvailabilityState {}

class BarberAvailabilityLoaded extends BarberAvailabilityState {
  final List<BarberAvailabilityEntity> availability;

  const BarberAvailabilityLoaded(this.availability);

  @override
  List<Object> get props => [availability];
}

class BarberAvailabilityError extends BarberAvailabilityState {
  final String message;

  const BarberAvailabilityError(this.message);

  @override
  List<Object> get props => [message];
}

class BarberAvailabilityUpdating extends BarberAvailabilityState {
  final List<BarberAvailabilityEntity> availability;

  const BarberAvailabilityUpdating(this.availability);

  @override
  List<Object> get props => [availability];
}

class BarberAvailabilityUpdated extends BarberAvailabilityState {
  final List<BarberAvailabilityEntity> availability;

  const BarberAvailabilityUpdated(this.availability);

  @override
  List<Object> get props => [availability];
}

