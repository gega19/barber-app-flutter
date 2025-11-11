import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/barber_entity.dart';
import '../common/app_button.dart';
import '../common/app_card.dart';
import '../common/app_avatar.dart';

bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

class BookingModal extends StatefulWidget {
  final BarberEntity barber;
  final VoidCallback onClose;
  final Function(DateTime, String, String)? onConfirm;

  const BookingModal({
    super.key,
    required this.barber,
    required this.onClose,
    this.onConfirm,
  });

  @override
  State<BookingModal> createState() => _BookingModalState();
}

class _BookingModalState extends State<BookingModal> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  String? _selectedPayment;
  int _currentStep = 0; // 0 = availability, 1 = payment

  final List<String> _availableSlots = [
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00'
  ];

  final List<Map<String, dynamic>> _paymentMethods = [
    {'id': 'cash', 'name': 'Efectivo', 'icon': '💵'},
    {'id': 'card', 'name': 'Tarjeta', 'icon': '💳'},
    {'id': 'transfer', 'name': 'Transferencia', 'icon': '📱'},
  ];

  void _handleNext() {
    if (_currentStep == 0) {
      if (_selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona una hora'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      setState(() => _currentStep = 1);
    } else {
      if (_selectedPayment == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona un método de pago'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      if (widget.onConfirm != null) {
        widget.onConfirm!(_selectedDate, _selectedTime!, _selectedPayment!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Cita reservada con ${widget.barber.name}!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
      widget.onClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black54,
        ),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            constraints: const BoxConstraints(maxHeight: 600),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primaryGold, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0F0F0F), Color(0xFF1A1A1A)],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    border: const Border(
                      bottom: BorderSide(color: AppColors.primaryGold, width: 2),
                    ),
                  ),
                  child: Row(
                    children: [
                      AppAvatar(
                        imageUrl: widget.barber.image,
                        name: widget.barber.name,
                        avatarSeed: widget.barber.avatarSeed,
                        size: 64,
                        borderColor: AppColors.primaryGold,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.barber.name,
                              style: const TextStyle(
                                color: AppColors.primaryGold,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: AppColors.primaryGold,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.barber.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: AppColors.primaryGold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  ' (${widget.barber.reviews} reseñas)',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryGold,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: AppColors.textDark,
                            size: 20,
                          ),
                        ),
                        onPressed: widget.onClose,
                      ),
                    ],
                  ),
                ),
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Info Cards
                        Row(
                          children: [
                            Expanded(
                              child: AppCard(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Precio',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '\$${widget.barber.price.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppCard(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Experiencia',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      widget.barber.experience,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Step Indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _currentStep == 0
                                    ? AppColors.primaryGold
                                    : AppColors.backgroundCardDark,
                                shape: BoxShape.circle,
                                border: _currentStep == 1
                                    ? Border.all(color: AppColors.primaryGold)
                                    : null,
                              ),
                              child: Icon(
                                Icons.calendar_today,
                                color: _currentStep == 0
                                    ? AppColors.textDark
                                    : AppColors.primaryGold,
                                size: 16,
                              ),
                            ),
                            Container(
                              width: 64,
                              height: 2,
                              color: _currentStep == 1
                                  ? AppColors.primaryGold
                                  : AppColors.textSecondary,
                            ),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _currentStep == 1
                                    ? AppColors.primaryGold
                                    : AppColors.textSecondary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.payment,
                                color: _currentStep == 1
                                    ? AppColors.textDark
                                    : Colors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (_currentStep == 0) _buildAvailabilityStep(),
                        if (_currentStep == 1) _buildPaymentStep(),
                      ],
                    ),
                  ),
                ),
                // Footer Buttons
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.borderGold, width: 1),
                    ),
                  ),
                  child: Column(
                    children: [
                      if (_currentStep == 1)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AppButton(
                            text: 'Volver a disponibilidad',
                            onPressed: () => setState(() => _currentStep = 0),
                            type: ButtonType.outline,
                          ),
                        ),
                      AppButton(
                        text: _currentStep == 0
                            ? 'Continuar al pago'
                            : 'Confirmar reserva',
                        onPressed: _handleNext,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvailabilityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Calendar
        const Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.textPrimary, size: 20),
            SizedBox(width: 8),
            Text(
              'Selecciona una fecha',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _selectedDate,
            selectedDayPredicate: (day) =>
                isSameDay(_selectedDate, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
              });
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
              defaultTextStyle: const TextStyle(
                color: AppColors.textPrimary,
              ),
              weekendTextStyle: const TextStyle(
                color: AppColors.textSecondary,
              ),
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
        const SizedBox(height: 24),
        // Time Slots
        const Row(
          children: [
            Icon(Icons.access_time, color: AppColors.textPrimary, size: 20),
            SizedBox(width: 8),
            Text(
              'Horarios disponibles',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _availableSlots.length,
          itemBuilder: (context, index) {
            final time = _availableSlots[index];
            final isSelected = _selectedTime == time;

            return InkWell(
              onTap: () => setState(() => _selectedTime = time),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryGold
                      : AppColors.backgroundCardDark,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryGold
                        : AppColors.borderGold,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    time,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.textDark
                          : AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPaymentStep() {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'es_ES');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Payment Methods
        const Row(
          children: [
            Icon(Icons.payment, color: AppColors.textPrimary, size: 20),
            SizedBox(width: 8),
            Text(
              'Método de pago',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._paymentMethods.map((method) {
          final isSelected = _selectedPayment == method['id'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => setState(() => _selectedPayment = method['id']),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryGold
                      : AppColors.backgroundCardDark,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryGold
                        : AppColors.borderGold,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      method['icon'] as String,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      method['name'] as String,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.textDark
                            : AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 24),
        // Summary
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Resumen de reserva',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildSummaryRow('Fecha:', dateFormat.format(_selectedDate)),
              const SizedBox(height: 8),
              _buildSummaryRow('Hora:', _selectedTime ?? ''),
              const SizedBox(height: 8),
              _buildSummaryRow(
                'Precio:',
                '\$${widget.barber.price.toStringAsFixed(0)}',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

