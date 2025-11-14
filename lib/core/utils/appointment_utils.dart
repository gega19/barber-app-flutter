import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../presentation/widgets/common/app_badge.dart';
import '../constants/app_constants.dart';

/// Utilidades compartidas para el manejo de citas
class AppointmentUtils {
  // Formateadores de fecha estáticos para evitar recrearlos
  static final DateFormat _fullDateFormat = DateFormat(
    'EEEE, d MMMM yyyy',
    'es_ES',
  );
  static final DateFormat _shortDateFormat = DateFormat('d MMM yyyy', 'es_ES');

  /// Formatea una fecha de cita en formato completo (ej: "Lunes, 15 Enero 2024")
  static String formatAppointmentDate(DateTime date) {
    return _fullDateFormat.format(date);
  }

  /// Formatea una fecha de cita en formato corto (ej: "15 Ene 2024")
  static String formatShortDate(DateTime date) {
    return _shortDateFormat.format(date);
  }

  /// Obtiene el label traducido para un método de pago
  static String getPaymentMethodLabel(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'Efectivo';
      case 'card':
        return 'Tarjeta';
      case 'transfer':
        return 'Transferencia';
      default:
        return method;
    }
  }

  /// Obtiene la configuración de estado (label, badge type, icon) para una cita
  static Map<String, dynamic> getStatusConfig(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.completed:
        return {
          'label': 'Completada',
          'badgeType': BadgeType.success,
          'icon': Icons.check_circle,
        };
      case AppointmentStatus.upcoming:
      case AppointmentStatus.pending:
        return {
          'label': status == AppointmentStatus.pending
              ? 'Pendiente'
              : 'Próxima',
          'badgeType': BadgeType.outline,
          'icon': Icons.access_time,
        };
      case AppointmentStatus.cancelled:
        return {
          'label': 'Cancelada',
          'badgeType': BadgeType.error,
          'icon': Icons.cancel,
        };
    }
  }

  /// Parsea la fecha y hora de una cita y las combina en un DateTime
  static DateTime parseAppointmentDateTime(AppointmentEntity appointment) {
    // Parsear la hora (formato "HH:mm")
    final timeParts = appointment.time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    // Combinar fecha y hora
    return DateTime(
      appointment.date.year,
      appointment.date.month,
      appointment.date.day,
      hour,
      minute,
    );
  }

  /// Verifica si una cita está próxima (pendiente o upcoming)
  static bool isUpcoming(AppointmentEntity appointment) {
    return appointment.status == AppointmentStatus.pending ||
        appointment.status == AppointmentStatus.upcoming;
  }

  /// Verifica si una cita puede ser cancelada
  /// (debe estar pendiente o upcoming y no haber pasado)
  static bool canCancel(AppointmentEntity appointment) {
    if (!isUpcoming(appointment)) return false;
    final appointmentDateTime = parseAppointmentDateTime(appointment);
    return appointmentDateTime.isAfter(DateTime.now());
  }

  /// Construye la URL completa de una imagen
  /// Delega a AppConstants.buildImageUrl para mantener consistencia
  static String buildImageUrl(String? url) {
    return AppConstants.buildImageUrl(url);
  }
}
