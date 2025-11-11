import '../../domain/entities/barber_availability_entity.dart';

class BarberAvailabilityModel extends BarberAvailabilityEntity {
  const BarberAvailabilityModel({
    required super.id,
    required super.barberId,
    required super.dayOfWeek,
    required super.startTime,
    required super.endTime,
    required super.isAvailable,
    super.breakStart,
    super.breakEnd,
  });

  factory BarberAvailabilityModel.fromJson(Map<String, dynamic> json) {
    return BarberAvailabilityModel(
      id: json['id'] as String,
      barberId: json['barberId'] as String,
      dayOfWeek: json['dayOfWeek'] as int,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      isAvailable: json['isAvailable'] as bool,
      breakStart: json['breakStart'] as String?,
      breakEnd: json['breakEnd'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barberId': barberId,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'isAvailable': isAvailable,
      if (breakStart != null) 'breakStart': breakStart,
      if (breakEnd != null) 'breakEnd': breakEnd,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'isAvailable': isAvailable,
      'breakStart': breakStart,
      'breakEnd': breakEnd,
    };
  }

  factory BarberAvailabilityModel.fromEntity(BarberAvailabilityEntity entity) {
    return BarberAvailabilityModel(
      id: entity.id,
      barberId: entity.barberId,
      dayOfWeek: entity.dayOfWeek,
      startTime: entity.startTime,
      endTime: entity.endTime,
      isAvailable: entity.isAvailable,
      breakStart: entity.breakStart,
      breakEnd: entity.breakEnd,
    );
  }
}

