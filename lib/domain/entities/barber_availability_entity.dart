import 'package:equatable/equatable.dart';

class BarberAvailabilityEntity extends Equatable {
  final String id;
  final String barberId;
  final int dayOfWeek; // 0 = Domingo, 1 = Lunes, ..., 6 = Sábado
  final String startTime; // "08:00"
  final String endTime; // "18:00"
  final bool isAvailable;
  final String? breakStart; // "13:00" (opcional)
  final String? breakEnd; // "14:00" (opcional)

  const BarberAvailabilityEntity({
    required this.id,
    required this.barberId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    this.breakStart,
    this.breakEnd,
  });

  String get dayName {
    switch (dayOfWeek) {
      case 0:
        return 'Domingo';
      case 1:
        return 'Lunes';
      case 2:
        return 'Martes';
      case 3:
        return 'Miércoles';
      case 4:
        return 'Jueves';
      case 5:
        return 'Viernes';
      case 6:
        return 'Sábado';
      default:
        return '';
    }
  }

  @override
  List<Object?> get props => [
        id,
        barberId,
        dayOfWeek,
        startTime,
        endTime,
        isAvailable,
        breakStart,
        breakEnd,
      ];
}

