import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/appointment_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_avatar.dart';
import '../../widgets/common/app_badge.dart';
import '../../widgets/common/app_button.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final AppointmentEntity appointment;

  const AppointmentDetailScreen({
    super.key,
    required this.appointment,
  });

  UserEntity? _getCurrentUser(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      return authState.user;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = _getCurrentUser(context);
    final isBarber = user?.role == 'BARBER';

    String? avatarUrl;
    String? avatarSeed;
    String name;
    String? specialtyOrPhone;
    String? email;

    if (isBarber) {
      name = appointment.client?.name ?? 'Cliente desconocido';
      avatarUrl = appointment.client?.avatar;
      avatarSeed = appointment.client?.avatarSeed;
      specialtyOrPhone = appointment.client?.phone;
      email = appointment.client?.email;
    } else {
      name = appointment.barber?.name ?? 'Barbero desconocido';
      avatarUrl = appointment.barber?.image;
      avatarSeed = appointment.barber?.avatarSeed;
      specialtyOrPhone = appointment.barber?.specialty;
    }

    final statusConfig = _getStatusConfig(appointment.status);
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'es_ES');

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A1A),
              Color(0xFF0F0F0F),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.borderGold, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundCardDark,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.borderGold),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.primaryGold,
                          size: 20,
                        ),
                      ),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Detalle de Cita',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    AppBadge(
                      text: statusConfig['label'] as String,
                      type: statusConfig['badgeType'] as BadgeType,
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Card
                      AppCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            AppAvatar(
                              imageUrl: avatarUrl,
                              name: name,
                              avatarSeed: avatarSeed,
                              size: 96,
                              borderColor: AppColors.primaryGold,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              name,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (specialtyOrPhone != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                specialtyOrPhone,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                            if (email != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                email,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Appointment Details
                      const Text(
                        'Información de la Cita',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildDetailRow(
                              Icons.calendar_today,
                              'Fecha',
                              dateFormat.format(appointment.date),
                            ),
                            Divider(color: AppColors.borderGold),
                            _buildDetailRow(
                              Icons.access_time,
                              'Hora',
                              appointment.time,
                            ),
                            if (appointment.paymentMethod != null) ...[
                              Divider(color: AppColors.borderGold),
                              _buildDetailRow(
                                Icons.payment,
                                'Método de Pago',
                                appointment.paymentMethodName ?? _getPaymentMethodLabel(appointment.paymentMethod!),
                              ),
                            ],
                            if (appointment.paymentStatus != null) ...[
                              Divider(color: AppColors.borderGold),
                              _buildPaymentStatusRow(),
                            ],
                            if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
                              Divider(color: AppColors.borderGold),
                              _buildDetailRow(
                                Icons.note,
                                'Notas',
                                appointment.notes!,
                                isMultiline: true,
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (appointment.serviceId != null) ...[
                        const SizedBox(height: 16),
                        AppCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.cut,
                                    color: AppColors.primaryGold,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Servicio',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 12),
                            // TODO: Agregar información del servicio cuando esté disponible en la entidad
                            Text(
                              'ID: ${appointment.serviceId ?? 'N/A'}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            ],
                          ),
                        ),
                      ],
                      // Payment Proof Section
                      if (appointment.paymentProof != null && appointment.paymentProof!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Comprobante de Pago',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        AppCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: GestureDetector(
                                  onTap: () {
                                    // Show full screen image
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => Scaffold(
                                          backgroundColor: Colors.black,
                                          appBar: AppBar(
                                            backgroundColor: Colors.transparent,
                                            iconTheme: const IconThemeData(color: Colors.white),
                                          ),
                                          body: Center(
                                            child: CachedNetworkImage(
                                              imageUrl: _getImageUrl(appointment.paymentProof!),
                                              fit: BoxFit.contain,
                                              placeholder: (context, url) => const Center(
                                                child: CircularProgressIndicator(
                                                  color: AppColors.primaryGold,
                                                ),
                                              ),
                                              errorWidget: (context, url, error) => const Icon(
                                                Icons.error,
                                                color: AppColors.error,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: CachedNetworkImage(
                                    imageUrl: _getImageUrl(appointment.paymentProof!),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 200,
                                    placeholder: (context, url) => Container(
                                      width: double.infinity,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        color: AppColors.backgroundCardDark,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.primaryGold,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      width: double.infinity,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        color: AppColors.backgroundCardDark,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.error,
                                          color: AppColors.error,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Toca la imagen para ver en pantalla completa',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      // Actions
                      if (appointment.status == AppointmentStatus.pending ||
                          appointment.status == AppointmentStatus.upcoming) ...[
                        AppButton(
                          text: 'Cancelar Cita',
                          onPressed: () {
                            // TODO: Implementar cancelación
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Funcionalidad de cancelación próximamente'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          },
                          type: ButtonType.outline,
                        ),
                      ],
                      if (appointment.status == AppointmentStatus.completed &&
                          appointment.rating == null) ...[
                        AppButton(
                          text: 'Calificar Cita',
                          onPressed: () {
                            // TODO: Implementar calificación
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Funcionalidad de calificación próximamente'),
                                backgroundColor: AppColors.primaryGold,
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    bool isMultiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primaryGold, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: isMultiline ? null : 1,
                  overflow: isMultiline ? null : TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPaymentMethodLabel(String method) {
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

  Widget _buildPaymentStatusRow() {
    final status = appointment.paymentStatus?.toUpperCase() ?? 'PENDING';
    String label;
    Color color;
    IconData icon;

    switch (status) {
      case 'PENDING':
        label = 'Pendiente de Verificación';
        color = AppColors.primaryGold;
        icon = Icons.pending;
        break;
      case 'VERIFIED':
        label = 'Pago Verificado';
        color = AppColors.success;
        icon = Icons.check_circle;
        break;
      case 'REJECTED':
        label = 'Pago Rechazado';
        color = AppColors.error;
        icon = Icons.cancel;
        break;
      default:
        label = 'Estado Desconocido';
        color = AppColors.textSecondary;
        icon = Icons.help_outline;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estado del Pago',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: color, width: 1),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getImageUrl(String url) {
    if (url.startsWith('http')) {
      return url;
    }
    return '${AppConstants.baseUrl}$url';
  }

  Map<String, dynamic> _getStatusConfig(AppointmentStatus status) {
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
          'label': status == AppointmentStatus.pending ? 'Pendiente' : 'Próxima',
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
}

