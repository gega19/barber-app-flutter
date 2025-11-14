import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/injection/injection.dart';
import '../../../core/utils/booking_utils.dart';
import '../../../domain/entities/barber_entity.dart';
import '../../../domain/entities/payment_method_entity.dart';
import '../../../domain/repositories/payment_method_repository.dart';
import '../../../data/models/service_model.dart';
import '../../../data/models/promotion_model.dart';
import '../../../data/datasources/remote/service_remote_datasource.dart';
import '../../../data/datasources/remote/barber_availability_remote_datasource.dart';
import '../../../data/datasources/remote/promotion_remote_datasource.dart';
import '../../cubit/payment_method/payment_method_cubit.dart';
import '../../cubit/appointment/appointment_cubit.dart';
import '../../widgets/booking/booking_header_widget.dart';
import '../../widgets/booking/booking_footer_widget.dart';
import '../../widgets/booking/service_selection_step.dart';
import '../../widgets/booking/availability_selection_step.dart';
import '../../widgets/booking/payment_selection_step.dart';
import '../../widgets/booking/summary_step.dart';
import '../../widgets/booking/step_indicator_widget.dart';
import 'payment_details_screen.dart';

bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

class BookingScreen extends StatefulWidget {
  final BarberEntity barber;

  const BookingScreen({super.key, required this.barber});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  String? _selectedPayment;
  String? _selectedService;
  String? _paymentProof; // URL del comprobante de pago
  int _currentStep =
      0; // 0 = service, 1 = availability, 2 = payment, 3 = summary
  List<ServiceModel> _services = [];
  bool _loadingServices = true;
  List<String> _availableSlots = [];
  bool _loadingSlots = false;
  List<PromotionModel> _promotions = [];
  final BarberAvailabilityRemoteDataSource _availabilityDataSource =
      sl<BarberAvailabilityRemoteDataSource>();
  final PaymentMethodRepository _paymentMethodRepository =
      sl<PaymentMethodRepository>();
  final PromotionRemoteDataSource _promotionDataSource =
      sl<PromotionRemoteDataSource>();

  // Cache para cálculos de precios
  Map<String, double>? _priceBreakdownCache;
  String? _lastCacheKey;

  @override
  void initState() {
    super.initState();
    _loadServices();
    _loadPromotions();
    context.read<PaymentMethodCubit>().loadPaymentMethods();
    _loadAvailableSlots();
  }

  Future<void> _loadPromotions() async {
    try {
      final promotions = await _promotionDataSource.getPromotionsByBarber(
        widget.barber.id,
      );
      if (mounted) {
        setState(() {
          _promotions = promotions;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _promotions = [];
        });
      }
    }
  }

  Future<void> _loadAvailableSlots() async {
    setState(() {
      _loadingSlots = true;
      _selectedTime = null; // Reset selected time when date changes
    });

    try {
      final dateStr = _selectedDate.toIso8601String().split(
        'T',
      )[0]; // Format: YYYY-MM-DD
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
      final services = await sl<ServiceRemoteDataSource>().getBarberServices(
        widget.barber.id,
      );
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
          final result = await _paymentMethodRepository
              .getPaymentMethodWithConfig(_selectedPayment!);

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

  PromotionModel? get _activePromotion {
    return BookingUtils.findActivePromotion(_promotions);
  }

  ServiceModel? get _selectedServiceModel {
    if (_selectedService == null) return null;
    try {
      return _services.firstWhere((s) => s.id == _selectedService);
    } catch (e) {
      return null;
    }
  }

  Map<String, double> get _priceBreakdown {
    // Crear una clave única para el cache basada en los parámetros relevantes
    final cacheKey =
        '${_selectedService}_${_activePromotion?.id ?? 'none'}_${widget.barber.price}';

    // Si la clave cambió, limpiar el cache
    if (_lastCacheKey != cacheKey) {
      _priceBreakdownCache = null;
      _lastCacheKey = cacheKey;
    }

    // Si hay cache, retornarlo
    if (_priceBreakdownCache != null) {
      return _priceBreakdownCache!;
    }

    // Calcular y cachear
    final breakdown = BookingUtils.calculatePriceBreakdown(
      service: _selectedServiceModel,
      barberPrice: widget.barber.price,
      promotion: _activePromotion,
    );

    _priceBreakdownCache = breakdown;
    return breakdown;
  }

  double get _basePrice => _priceBreakdown['basePrice']!;
  double get _discountAmount => _priceBreakdown['discountAmount']!;
  double get _totalPrice => _priceBreakdown['totalPrice']!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0F0F), Color(0xFF1A1A1A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              RepaintBoundary(
                child: BookingHeaderWidget(barber: widget.barber),
              ),
              // Step Indicator
              RepaintBoundary(
                child: StepIndicatorWidget(
                  currentStep: _currentStep,
                  steps: const [
                    StepData(icon: Icons.cut, label: 'Servicio'),
                    StepData(icon: Icons.calendar_today, label: 'Fecha'),
                    StepData(icon: Icons.payment, label: 'Pago'),
                    StepData(icon: Icons.check_circle, label: 'Confirmar'),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_currentStep == 0)
                        RepaintBoundary(
                          child: ServiceSelectionStep(
                            services: _services,
                            loadingServices: _loadingServices,
                            selectedServiceId: _selectedService,
                            activePromotion: _activePromotion,
                            onServiceSelected: (serviceId) {
                              setState(() {
                                _selectedService = serviceId;
                                // Limpiar cache cuando cambia el servicio
                                _priceBreakdownCache = null;
                                _lastCacheKey = null;
                              });
                            },
                          ),
                        )
                            .animate(key: ValueKey('step_0'))
                            .fadeIn(duration: 300.ms)
                            .slideX(begin: 0.1, end: 0, duration: 300.ms),
                      if (_currentStep == 1)
                        RepaintBoundary(
                          child: AvailabilitySelectionStep(
                            selectedDate: _selectedDate,
                            selectedTime: _selectedTime,
                            availableSlots: _availableSlots,
                            loadingSlots: _loadingSlots,
                            onDateSelected: (date) {
                              setState(() {
                                _selectedDate = date;
                                _selectedTime = null;
                                // Limpiar cache de precios cuando cambia la fecha
                                _priceBreakdownCache = null;
                                _lastCacheKey = null;
                              });
                              _loadAvailableSlots();
                            },
                            onTimeSelected: (time) {
                              setState(() => _selectedTime = time);
                            },
                          ),
                        )
                            .animate(key: ValueKey('step_1'))
                            .fadeIn(duration: 300.ms)
                            .slideX(begin: 0.1, end: 0, duration: 300.ms),
                      if (_currentStep == 2)
                        RepaintBoundary(
                          child: PaymentSelectionStep(
                            selectedPaymentId: _selectedPayment,
                            onPaymentSelected: (paymentId) {
                              setState(() => _selectedPayment = paymentId);
                            },
                          ),
                        )
                            .animate(key: ValueKey('step_2'))
                            .fadeIn(duration: 300.ms)
                            .slideX(begin: 0.1, end: 0, duration: 300.ms),
                      if (_currentStep == 3)
                        RepaintBoundary(
                          child: SummaryStep(
                            selectedService: _selectedServiceModel!,
                            selectedDate: _selectedDate,
                            selectedTime: _selectedTime!,
                            selectedPaymentId: _selectedPayment,
                            activePromotion: _activePromotion,
                            basePrice: _basePrice,
                            discountAmount: _discountAmount,
                            totalPrice: _totalPrice,
                          ),
                        )
                            .animate(key: ValueKey('step_3'))
                            .fadeIn(duration: 300.ms)
                            .slideX(begin: 0.1, end: 0, duration: 300.ms),
                    ],
                  ),
                ),
              ),
              // Footer
              RepaintBoundary(
                child: BookingFooterWidget(
                  currentStep: _currentStep,
                  onBack: _currentStep > 0
                      ? () => setState(() => _currentStep--)
                      : null,
                  onNext: _handleNext,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Métodos _build* eliminados - ahora se usan widgets extraídos
}
