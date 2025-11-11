import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/injection/injection.dart';
import '../../../domain/entities/barber_entity.dart';
import '../../../domain/entities/payment_method_entity.dart';
import '../../../domain/repositories/payment_method_repository.dart';
import '../../../data/models/service_model.dart';
import '../../../data/datasources/remote/service_remote_datasource.dart';
import '../../../data/datasources/remote/barber_availability_remote_datasource.dart';
import '../../cubit/payment_method/payment_method_cubit.dart';
import '../../cubit/appointment/appointment_cubit.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_avatar.dart';
import 'payment_details_screen.dart';

bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

class BookingScreen extends StatefulWidget {
  final BarberEntity barber;

  const BookingScreen({
    super.key,
    required this.barber,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  String? _selectedPayment;
  String? _selectedService;
  String? _paymentProof; // URL del comprobante de pago
  int _currentStep = 0; // 0 = service, 1 = availability, 2 = payment, 3 = summary
  List<ServiceModel> _services = [];
  bool _loadingServices = true;
  List<String> _availableSlots = [];
  bool _loadingSlots = false;
  final BarberAvailabilityRemoteDataSource _availabilityDataSource = sl<BarberAvailabilityRemoteDataSource>();
  final PaymentMethodRepository _paymentMethodRepository = sl<PaymentMethodRepository>();

  @override
  void initState() {
    super.initState();
    _loadServices();
    context.read<PaymentMethodCubit>().loadPaymentMethods();
    _loadAvailableSlots();
  }

  Future<void> _loadAvailableSlots() async {
    setState(() {
      _loadingSlots = true;
      _selectedTime = null; // Reset selected time when date changes
    });

    try {
      final dateStr = _selectedDate.toIso8601String().split('T')[0]; // Format: YYYY-MM-DD
      final slots = await _availabilityDataSource.getAvailableSlots(
        widget.barber.id,
        dateStr,
      );
      
      if (mounted) {
        setState(() {
          _availableSlots = slots;
          _loadingSlots = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _availableSlots = [];
          _loadingSlots = false;
        });
      }
    }
  }

  Future<void> _loadServices() async {
    setState(() {
      _loadingServices = true;
    });

    try {
      final services = await sl<ServiceRemoteDataSource>().getBarberServices(widget.barber.id);
      setState(() {
        _services = services;
        _loadingServices = false;
      });
    } catch (e) {
      setState(() {
        _loadingServices = false;
      });
    }
  }

  Future<void> _handleNext() async {
    if (_currentStep == 0) {
      if (_selectedService == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona un servicio'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      if (_selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona una hora'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      if (_selectedPayment == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona un método de pago'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      // Check if payment method has config (needs payment details screen)
      if (_selectedPayment != null) {
        PaymentMethodEntity? methodToUse;
        
        try {
          // Always try to fetch the payment method with config to ensure we have the latest data
          final result = await _paymentMethodRepository.getPaymentMethodWithConfig(_selectedPayment!);
          
          result.fold(
            (failure) {
              // If we can't fetch config, check if the method from the list has config
              final paymentMethods = context.read<PaymentMethodCubit>().state;
              if (paymentMethods is PaymentMethodLoaded) {
                try {
                  final method = paymentMethods.paymentMethods.firstWhere(
                    (m) => m.id == _selectedPayment,
                  );
                  methodToUse = method;
                } catch (e) {
                  // Method not found in list
                }
              }
            },
            (methodWithConfig) {
              methodToUse = methodWithConfig;
            },
          );
          
          // If method has type and config, navigate to payment details screen
          if (methodToUse != null &&
              methodToUse!.type != null && 
              methodToUse!.config != null && 
              methodToUse!.config!.isNotEmpty) {
            await _navigateToPaymentDetails(methodToUse!);
            return;
          }
        } catch (e) {
          // Error fetching method, continue normally
          if (mounted) {
            debugPrint('Error fetching payment method config: $e');
          }
        }
      }
      setState(() => _currentStep = 3);
    } else {
      // Confirm booking
      _confirmBooking();
    }
  }

  Future<void> _navigateToPaymentDetails(PaymentMethodEntity method) async {
    final proofUrl = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentDetailsScreen(
          paymentMethod: method,
          barberId: widget.barber.id,
          serviceId: _selectedService,
          date: _selectedDate,
          time: _selectedTime!,
          price: _totalPrice,
        ),
      ),
    );
    if (proofUrl != null && mounted) {
      setState(() {
        _paymentProof = proofUrl;
      });
      setState(() => _currentStep = 3);
    }
  }

  Future<void> _confirmBooking() async {
    if (_selectedTime == null || _selectedPayment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final appointmentCubit = context.read<AppointmentCubit>();
    
    final success = await appointmentCubit.createAppointment(
      barberId: widget.barber.id,
      serviceId: _selectedService,
      date: _selectedDate,
      time: _selectedTime!,
      paymentMethod: _selectedPayment!,
      paymentProof: _paymentProof,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Cita reservada con ${widget.barber.name}!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else {
      final state = appointmentCubit.state;
      if (state is AppointmentError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  double get _totalPrice {
    if (_selectedService == null) {
      return widget.barber.price;
    }
    final service = _services.firstWhere((s) => s.id == _selectedService);
    return service.price;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F0F0F),
              Color(0xFF1A1A1A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              // Step Indicator
              _buildStepIndicator(),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_currentStep == 0) _buildServiceStep(),
                      if (_currentStep == 1) _buildAvailabilityStep(),
                      if (_currentStep == 2) _buildPaymentStep(),
                      if (_currentStep == 3) _buildSummaryStep(),
                    ],
                  ),
                ),
              ),
              // Footer
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          AppAvatar(
            imageUrl: widget.barber.image,
            name: widget.barber.name,
            avatarSeed: widget.barber.avatarSeed,
            size: 48,
            borderColor: AppColors.primaryGold,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.barber.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 14,
                      color: AppColors.primaryGold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.barber.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
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

  Widget _buildStepIndicator() {
    final steps = [
      {'icon': Icons.cut, 'label': 'Servicio'},
      {'icon': Icons.calendar_today, 'label': 'Fecha'},
      {'icon': Icons.payment, 'label': 'Pago'},
      {'icon': Icons.check_circle, 'label': 'Confirmar'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 2,
                        color: isCompleted || isActive
                            ? AppColors.primaryGold
                            : AppColors.textSecondary.withValues(alpha: 0.3),
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isActive || isCompleted
                            ? AppColors.primaryGold
                            : AppColors.backgroundCardDark,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isActive || isCompleted
                              ? AppColors.primaryGold
                              : AppColors.borderGold,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        step['icon'] as IconData,
                        color: isActive || isCompleted
                            ? AppColors.textDark
                            : AppColors.textSecondary,
                        size: 18,
                      ),
                    ),
                    if (index < steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isCompleted
                              ? AppColors.primaryGold
                              : AppColors.textSecondary.withValues(alpha: 0.3),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  step['label'] as String,
                  style: TextStyle(
                    color: isActive
                        ? AppColors.primaryGold
                        : AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildServiceStep() {
    if (_loadingServices) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryGold,
        ),
      );
    }

    if (_services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cut_outlined,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay servicios disponibles',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecciona un servicio',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Elige el servicio que deseas reservar',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        ..._services.map((service) {
          final isSelected = _selectedService == service.id;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => setState(() => _selectedService = service.id),
              borderRadius: BorderRadius.circular(12),
              child: AppCard(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryGold.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryGold
                          : AppColors.borderGold,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryGold
                              : AppColors.backgroundCardDark,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.cut,
                          color: isSelected
                              ? AppColors.textDark
                              : AppColors.primaryGold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.name,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.primaryGold
                                    : AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (service.description != null && service.description!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                service.description!,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Text(
                        '\$${service.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primaryGold
                              : AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAvailabilityStep() {
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
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        // Calendar
        AppCard(
          padding: const EdgeInsets.all(16),
          child: TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _selectedDate,
            selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
                _selectedTime = null; // Reset time when date changes
              });
              _loadAvailableSlots(); // Load slots for the selected date
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
        const Text(
          'Horarios disponibles',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        if (_loadingSlots)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(
                color: AppColors.primaryGold,
              ),
            ),
          )
        else if (_availableSlots.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 48,
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay horarios disponibles para esta fecha',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
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
            itemCount: _availableSlots.length,
            itemBuilder: (context, index) {
              final time = _availableSlots[index];
              final isSelected = _selectedTime == time;

              return InkWell(
                onTap: () => setState(() => _selectedTime = time),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryGold
                        : AppColors.backgroundCardDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryGold
                          : AppColors.borderGold,
                      width: isSelected ? 2 : 1,
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
    return BlocBuilder<PaymentMethodCubit, PaymentMethodState>(
      builder: (context, state) {
        if (state is PaymentMethodLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryGold,
            ),
          );
        }

        if (state is PaymentMethodError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final paymentMethods = state is PaymentMethodLoaded ? state.paymentMethods : <PaymentMethodEntity>[];

        if (paymentMethods.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.payment_outlined,
                  size: 64,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay métodos de pago disponibles',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Método de pago',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Elige cómo deseas pagar',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ...paymentMethods.map((method) {
              final isSelected = _selectedPayment == method.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => setState(() => _selectedPayment = method.id),
                  borderRadius: BorderRadius.circular(12),
                  child: AppCard(
                    padding: EdgeInsets.zero,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryGold.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryGold
                              : AppColors.borderGold,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            method.icon ?? '💳',
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              method.name,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.primaryGold
                                    : AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.primaryGold,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildSummaryStep() {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'es_ES');
    final selectedService = _services.firstWhere((s) => s.id == _selectedService);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumen de tu cita',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildSummaryRow(
                'Servicio',
                selectedService.name,
                Icons.cut,
              ),
              Divider(color: AppColors.borderGold),
              _buildSummaryRow(
                'Fecha',
                dateFormat.format(_selectedDate),
                Icons.calendar_today,
              ),
              Divider(color: AppColors.borderGold),
              _buildSummaryRow(
                'Hora',
                _selectedTime ?? '',
                Icons.access_time,
              ),
              Divider(color: AppColors.borderGold),
              BlocBuilder<PaymentMethodCubit, PaymentMethodState>(
                builder: (context, state) {
                  String paymentMethodName = '';
                  if (state is PaymentMethodLoaded && _selectedPayment != null) {
                    try {
                      final method = state.paymentMethods.firstWhere(
                        (m) => m.id == _selectedPayment,
                      );
                      paymentMethodName = method.name;
                    } catch (e) {
                      paymentMethodName = 'No seleccionado';
                    }
                  }
                  return _buildSummaryRow(
                    'Método de pago',
                    paymentMethodName,
                    Icons.payment,
                  );
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryGold),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total a pagar',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${_totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppColors.primaryGold,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        border: Border(
          top: BorderSide(color: AppColors.borderGold, width: 1),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: AppButton(
                text: 'Volver',
                onPressed: () => setState(() => _currentStep--),
                type: ButtonType.outline,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: BlocBuilder<AppointmentCubit, AppointmentState>(
              builder: (context, state) {
                final isCreating = state is AppointmentCreating;
                return AppButton(
                  text: _currentStep == 0
                      ? 'Continuar'
                      : _currentStep == 3
                          ? (isCreating ? 'Confirmando...' : 'Confirmar')
                          : 'Siguiente',
                  onPressed: isCreating ? null : _handleNext,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

