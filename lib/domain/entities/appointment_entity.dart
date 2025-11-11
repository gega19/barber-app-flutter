import 'package:equatable/equatable.dart';
import 'barber_entity.dart';
import 'user_entity.dart';

/// Estados de una cita
enum AppointmentStatus {
  upcoming,
  completed,
  cancelled,
  pending,
}

/// Entidad de cita del dominio
class AppointmentEntity extends Equatable {
  final String id;
  final BarberEntity? barber;
  final UserEntity? client;
  final String? serviceId;
  final DateTime date;
  final String time;
  final double? price;
  final AppointmentStatus status;
  final String? paymentMethod; // ID del método de pago
  final String? paymentMethodName; // Nombre del método de pago
  final String? paymentStatus; // 'PENDING', 'VERIFIED', 'REJECTED'
  final String? paymentProof; // URL del comprobante de pago
  final String? notes;
  final int? rating;

  const AppointmentEntity({
    required this.id,
    this.barber,
    this.client,
    this.serviceId,
    required this.date,
    required this.time,
    this.price,
    required this.status,
    this.paymentMethod,
    this.paymentMethodName,
    this.paymentStatus,
    this.paymentProof,
    this.notes,
    this.rating,
  });

  @override
  List<Object?> get props => [id, barber, client, serviceId, date, time, price, status, paymentMethod, paymentMethodName, paymentStatus, paymentProof, notes, rating];
}


