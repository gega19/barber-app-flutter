import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/appointment_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../cubit/appointment/appointment_cubit.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_avatar.dart';
import '../../widgets/common/app_badge.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<AppointmentCubit>().loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<AppointmentEntity> _filterAppointments(
    List<AppointmentEntity> appointments,
    int tabIndex,
  ) {
    List<AppointmentEntity> filtered;
    
    if (tabIndex == 0) {
      filtered = appointments;
    } else if (tabIndex == 1) {
      filtered = appointments
          .where((a) => a.status == AppointmentStatus.pending ||
              a.status == AppointmentStatus.upcoming)
          .toList();
    } else {
      filtered = appointments
          .where((a) => a.status == AppointmentStatus.completed)
          .toList();
    }

    // Ordenar por fecha y hora (más próximas primero)
    filtered.sort((a, b) {
      // Combinar fecha y hora para comparar
      final dateTimeA = _getAppointmentDateTime(a);
      final dateTimeB = _getAppointmentDateTime(b);
      return dateTimeA.compareTo(dateTimeB);
    });

    return filtered;
  }

  DateTime _getAppointmentDateTime(AppointmentEntity appointment) {
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

  UserEntity? _getCurrentUser() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      return authState.user;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = _getCurrentUser();
    final isBarber = user?.role == 'BARBER';

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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Citas',
                      style: TextStyle(
                        color: AppColors.primaryGold,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isBarber
                          ? 'Tus citas programadas y completadas'
                          : 'Tus citas pasadas y futuras',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<AppointmentCubit, AppointmentState>(
                      builder: (context, state) {
                        if (state is AppointmentLoaded) {
                          final all = state.appointments;
                          final upcoming = all
                              .where((a) =>
                                  a.status == AppointmentStatus.pending ||
                                  a.status == AppointmentStatus.upcoming)
                              .toList();
                          return Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGold
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.borderGold,
                                    ),
                                  ),
                                  child: Text(
                                    '${all.length} Total',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppColors.primaryGold,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGold
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.borderGold,
                                    ),
                                  ),
                                  child: Text(
                                    '${upcoming.length} Próximas',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppColors.primaryGold,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderGold),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primaryGold,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: AppColors.textDark,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicator: BoxDecoration(
                    color: AppColors.primaryGold,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  tabs: const [
                    Tab(text: 'Todas'),
                    Tab(text: 'Próximas'),
                    Tab(text: 'Completadas'),
                  ],
                  onTap: (index) {
                    setState(() {});
                  },
                ),
              ),
              Expanded(
                child: BlocBuilder<AppointmentCubit, AppointmentState>(
                  builder: (context, state) {
                    if (state is AppointmentLoading) {
                      return const LoadingWidget();
                    }

                    if (state is AppointmentError) {
                      return AppErrorWidget(
                        message: state.message,
                        onRetry: () {
                          context.read<AppointmentCubit>().loadAppointments();
                        },
                      );
                    }

                    if (state is AppointmentLoaded) {
                      final filtered = _filterAppointments(
                        state.appointments,
                        _tabController.index,
                      );
                      return _buildAppointmentsList(filtered, isBarber);
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentsList(
    List<AppointmentEntity> appointments,
    bool isBarber,
  ) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getEmptyIcon(),
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyMessage(),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<AppointmentCubit>().loadAppointments();
      },
      color: AppColors.primaryGold,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          return _buildAppointmentCard(appointments[index], isBarber);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(
    AppointmentEntity appointment,
    bool isBarber,
  ) {
    final statusConfig = _getStatusConfig(appointment.status);
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'es_ES');

    String? avatarUrl;
    String? avatarSeed;
    String name;
    String? specialtyOrPhone;

    if (isBarber) {
      name = appointment.client?.name ?? 'Cliente desconocido';
      avatarUrl = appointment.client?.avatar;
      avatarSeed = appointment.client?.avatarSeed;
      specialtyOrPhone = appointment.client?.phone;
    } else {
      name = appointment.barber?.name ?? 'Barbero desconocido';
      avatarUrl = appointment.barber?.image;
      avatarSeed = appointment.barber?.avatarSeed;
      specialtyOrPhone = appointment.barber?.specialty;
    }

    return AppCard(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      onTap: () {
        context.push('/appointment/${appointment.id}');
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppAvatar(
            imageUrl: avatarUrl,
            name: name,
            avatarSeed: avatarSeed,
            size: 64,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    AppBadge(
                      text: statusConfig['label'] as String,
                      type: statusConfig['badgeType'] as BadgeType,
                    ),
                  ],
                ),
                if (specialtyOrPhone != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    specialtyOrPhone,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        dateFormat.format(appointment.date),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      appointment.time,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                if (appointment.paymentMethod != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.payment,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getPaymentMethodLabel(appointment.paymentMethod!),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
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

  IconData _getEmptyIcon() {
    if (_tabController.index == 0) return Icons.event_note;
    if (_tabController.index == 1) return Icons.access_time;
    return Icons.check_circle;
  }

  String _getEmptyMessage() {
    if (_tabController.index == 0) return 'No tienes citas registradas';
    if (_tabController.index == 1) return 'No tienes citas próximas';
    return 'No tienes citas completadas';
  }
}


