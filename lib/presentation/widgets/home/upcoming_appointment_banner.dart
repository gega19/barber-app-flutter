import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../cubit/appointment/appointment_cubit.dart';
import '../../../domain/entities/appointment_entity.dart';
import '../../../core/constants/app_colors.dart';

class UpcomingAppointmentBanner extends StatefulWidget {
  const UpcomingAppointmentBanner({super.key});

  @override
  State<UpcomingAppointmentBanner> createState() =>
      _UpcomingAppointmentBannerState();
}

class _UpcomingAppointmentBannerState extends State<UpcomingAppointmentBanner> {
  bool _isExpanded = false;

  AppointmentEntity? _getNearestAppointment(
    List<AppointmentEntity> appointments,
  ) {
    // Filtrar solo citas futuras (pending o upcoming)
    final upcoming = appointments.where((apt) {
      if (apt.status == AppointmentStatus.cancelled ||
          apt.status == AppointmentStatus.completed) {
        return false;
      }
      return _getHoursDiff(apt.date, apt.time) >= 0;
    }).toList();

    if (upcoming.isEmpty) return null;

    // Ordenar por cercanía
    upcoming.sort((a, b) {
      final diffA = _getHoursDiff(a.date, a.time);
      final diffB = _getHoursDiff(b.date, b.time);
      return diffA.compareTo(diffB);
    });

    final nearest = upcoming.first;
    // Solo mostramos si faltan menos de 24 horas (y no ha pasado)
    final diff = _getHoursDiff(nearest.date, nearest.time);
    if (diff >= 0 && diff <= 24) {
      return nearest;
    }
    return null;
  }

  int _getHoursDiff(DateTime aptDate, String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      // Use local date from API, set hours/mins
      final appointmentDateTime = DateTime(
        aptDate.year,
        aptDate.month,
        aptDate.day,
        hour,
        minute,
      );
      final now = DateTime.now();

      // Calculate strict difference
      final diff = appointmentDateTime.difference(now);
      return diff.inHours;
    } catch (_) {
      return -1;
    }
  }

  String _getTimeRemainingLabel(DateTime aptDate, String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final appointmentDateTime = DateTime(
        aptDate.year,
        aptDate.month,
        aptDate.day,
        hour,
        minute,
      );
      final now = DateTime.now();

      final diff = appointmentDateTime.difference(now);

      // Round up hours if there are remaining minutes
      final totalHours = diff.inHours;
      final remainingMinutes = diff.inMinutes % 60;

      if (totalHours > 0) {
        // Option to display precise if expanded, but let's keep it simple
        return 'En $totalHours ${totalHours == 1 ? 'hora' : 'h'} ${remainingMinutes > 0 ? '${remainingMinutes}m' : ''}';
      } else if (diff.inMinutes > 0) {
        return 'En ${diff.inMinutes} ${diff.inMinutes == 1 ? 'min' : 'mins'}';
      } else {
        return '¡Es hora!';
      }
    } catch (_) {
      return 'Pronto';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentCubit, AppointmentState>(
      builder: (context, state) {
        if (state is AppointmentLoaded) {
          final nearest = _getNearestAppointment(state.appointments);

          if (nearest != null) {
            return _buildBanner(context, nearest);
          }
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBanner(BuildContext context, AppointmentEntity apt) {
    final dateFormat = DateFormat('dd MMM', 'es');
    final barberName = apt.barber?.name ?? 'tu barbero';
    final timeLabel = _getTimeRemainingLabel(apt.date, apt.time);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF333333), Color(0xFF222222)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            border: Border.all(
              color: AppColors.primaryGold.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGold.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: _isExpanded ? 16 : 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Collapsed Header
              Row(
                children: [
                  const Icon(
                    Icons.access_time_filled,
                    color: AppColors.primaryGold,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tu próxima cita: $timeLabel',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),

              // Expanded Content
              if (_isExpanded) ...[
                const SizedBox(height: 16),
                const Divider(color: Colors.white10, height: 1),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Con $barberName',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${dateFormat.format(apt.date)} a las ${apt.time}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.push('/appointment/${apt.id}', extra: apt);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold.withOpacity(0.1),
                        foregroundColor: AppColors.primaryGold,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: AppColors.primaryGold.withOpacity(0.5),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Ver detalles',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
