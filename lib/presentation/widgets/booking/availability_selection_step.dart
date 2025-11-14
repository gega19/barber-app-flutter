import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../common/app_card.dart';
import 'time_slot_widget.dart';
import 'time_slot_skeleton.dart';

bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Widget para el paso de selección de fecha y hora
class AvailabilitySelectionStep extends StatelessWidget {
  final DateTime selectedDate;
  final String? selectedTime;
  final List<String> availableSlots;
  final bool loadingSlots;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<String> onTimeSelected;

  const AvailabilitySelectionStep({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.availableSlots,
    required this.loadingSlots,
    required this.onDateSelected,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecciona fecha y hora',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Elige cuándo deseas tu cita',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 24),
        // Calendar
        RepaintBoundary(
          child: AppCard(
            padding: const EdgeInsets.all(16),
            child: TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: selectedDate,
            selectedDayPredicate: (day) => isSameDay(selectedDate, day),
            onDaySelected: (selectedDay, focusedDay) {
              onDateSelected(selectedDay);
            },
            enabledDayPredicate: (day) {
              return day.isAfter(
                DateTime.now().subtract(const Duration(days: 1)),
              );
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: AppColors.primaryGold.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: AppColors.primaryGold,
                shape: BoxShape.circle,
              ),
              defaultTextStyle: const TextStyle(color: AppColors.textPrimary),
              weekendTextStyle: const TextStyle(color: AppColors.textSecondary),
              disabledTextStyle: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              leftChevronIcon: const Icon(
                Icons.chevron_left,
                color: AppColors.primaryGold,
              ),
              rightChevronIcon: const Icon(
                Icons.chevron_right,
                color: AppColors.primaryGold,
              ),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: AppColors.textSecondary),
              weekendStyle: TextStyle(color: AppColors.textSecondary),
            ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Time Slots
        const Text(
          'Horarios disponibles',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        if (loadingSlots)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return const TimeSlotSkeleton();
            },
          )
        else if (availableSlots.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 48,
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .scale(delay: 200.ms, duration: 300.ms),
                  const SizedBox(height: 16),
                  Text(
                    'No hay horarios disponibles para esta fecha',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 300.ms)
                      .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: 300.ms),
                ],
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: availableSlots.length,
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: true,
            addSemanticIndexes: false,
            itemBuilder: (context, index) {
              final time = availableSlots[index];
              return RepaintBoundary(
                child: TimeSlotWidget(
                  time: time,
                  isSelected: selectedTime == time,
                  onTap: () => onTimeSelected(time),
                ),
              )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: Duration(milliseconds: index * 30))
                  .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 300.ms, delay: Duration(milliseconds: index * 30));
            },
          ),
      ],
    );
  }
}
