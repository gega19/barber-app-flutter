part of 'barber_cubit.dart';

abstract class BarberState extends Equatable {
  const BarberState();

  @override
  List<Object?> get props => [];
}

class BarberInitial extends BarberState {}

class BarberLoading extends BarberState {}

class BarberLoaded extends BarberState {
  final List<BarberEntity> barbers;

  const BarberLoaded(this.barbers);

  @override
  List<Object?> get props => [barbers];
}

class BarberError extends BarberState {
  final String message;

  const BarberError(this.message);

  @override
  List<Object?> get props => [message];
}


