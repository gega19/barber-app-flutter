import '../../domain/entities/appointment_entity.dart';
import '../../domain/entities/barber_entity.dart';
import '../../domain/entities/user_entity.dart';
import 'barber_model.dart';
import 'user_model.dart';

class AppointmentModel extends AppointmentEntity {
  const AppointmentModel({
    required super.id,
    super.barber,
    super.client,
    super.serviceId,
    required super.date,
    required super.time,
    super.price,
    required super.status,
    super.paymentMethod,
    super.paymentMethodName,
    super.paymentStatus,
    super.paymentProof,
    super.notes,
    super.rating,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    BarberEntity? barber;
    UserEntity? client;

    if (json['barber'] != null) {
      barber = BarberModel.fromJson(json['barber'] as Map<String, dynamic>);
    }

    if (json['client'] != null) {
      client = UserModel.fromJson(json['client'] as Map<String, dynamic>);
    }

    AppointmentStatus status = AppointmentStatus.pending;
    final rawStatus = json['status'];
    final statusStr = rawStatus != null
        ? (rawStatus.toString().toUpperCase().trim())
        : 'PENDING';

    switch (statusStr) {
      case 'COMPLETED':
        status = AppointmentStatus.completed;
        break;
      case 'CANCELLED':
        status = AppointmentStatus.cancelled;
        break;
      case 'UPCOMING':
        status = AppointmentStatus.upcoming;
        break;
      case 'PENDING':
        status = AppointmentStatus.pending;
        break;
      default:
        // Si el status no coincide con ninguno conocido, mantener como pending
        // pero loguear para debug
        print(
          '⚠️ Unknown appointment status: "$statusStr" (raw: $rawStatus), defaulting to pending',
        );
        status = AppointmentStatus.pending;
        break;
    }

    final dateStr = json['date'] as String;
    final date = DateTime.parse(dateStr);

    return AppointmentModel(
      id: json['id'] as String,
      barber: barber,
      client: client,
      serviceId: json['serviceId'] as String?,
      date: date,
      time: json['time'] as String,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      status: status,
      paymentMethod: json['paymentMethod'] as String?,
      paymentMethodName: json['paymentMethodName'] as String?,
      paymentStatus: json['paymentStatus'] as String?,
      paymentProof: json['paymentProof'] as String?,
      notes: json['notes'] as String?,
      rating: json['rating'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barber': barber != null ? (barber as BarberModel).toJson() : null,
      'client': client != null ? (client as UserModel).toJson() : null,
      'serviceId': serviceId,
      'date': date.toIso8601String(),
      'time': time,
      'price': price,
      'status': status.toString(),
      'paymentMethod': paymentMethod,
      'paymentMethodName': paymentMethodName,
      'paymentStatus': paymentStatus,
      'paymentProof': paymentProof,
      'notes': notes,
      'rating': rating,
    };
  }

  factory AppointmentModel.fromEntity(AppointmentEntity entity) {
    return AppointmentModel(
      id: entity.id,
      barber: entity.barber,
      client: entity.client,
      serviceId: entity.serviceId,
      date: entity.date,
      time: entity.time,
      price: entity.price,
      status: entity.status,
      paymentMethod: entity.paymentMethod,
      paymentMethodName: entity.paymentMethodName,
      paymentStatus: entity.paymentStatus,
      paymentProof: entity.paymentProof,
      notes: entity.notes,
      rating: entity.rating,
    );
  }
}
