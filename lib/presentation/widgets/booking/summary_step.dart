import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/appointment_utils.dart';
import '../../../data/models/service_model.dart';
import '../../../data/models/promotion_model.dart';
import '../../cubit/payment_method/payment_method_cubit.dart';
import '../common/app_card.dart';
import 'price_breakdown_widget.dart';

/// Widget para el paso de resumen de la cita
class SummaryStep extends StatelessWidget {
  final ServiceModel selectedService;
  final DateTime selectedDate;
  final String selectedTime;
  final String? selectedPaymentId;
  final PromotionModel? activePromotion;
  final double basePrice;
  final double discountAmount;
  final double totalPrice;

  const SummaryStep({
    super.key,
    required this.selectedService,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedPaymentId,
    this.activePromotion,
    required this.basePrice,
    required this.discountAmount,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
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
          RepaintBoundary(
            child: AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildSummaryRow('Servicio', selectedService.name, Icons.cut)
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 0.ms)
                      .slideX(begin: -0.1, end: 0, duration: 300.ms, delay: 0.ms),
                  Divider(color: AppColors.borderGold),
                  _buildSummaryRow(
                    'Fecha',
                    AppointmentUtils.formatAppointmentDate(selectedDate),
                    Icons.calendar_today,
                  )
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 100.ms)
                      .slideX(begin: -0.1, end: 0, duration: 300.ms, delay: 100.ms),
                  Divider(color: AppColors.borderGold),
                  _buildSummaryRow('Hora', selectedTime, Icons.access_time)
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 200.ms)
                      .slideX(begin: -0.1, end: 0, duration: 300.ms, delay: 200.ms),
                  Divider(color: AppColors.borderGold),
                  BlocBuilder<PaymentMethodCubit, PaymentMethodState>(
                    buildWhen: (previous, current) {
                      // Solo rebuild si cambia el estado o el método seleccionado
                      if (previous.runtimeType != current.runtimeType) return true;
                      if (previous is PaymentMethodLoaded && current is PaymentMethodLoaded) {
                        // Rebuild si cambió el método seleccionado o la lista de métodos
                        if (previous.paymentMethods.length != current.paymentMethods.length) return true;
                        if (selectedPaymentId != null) {
                          try {
                            final prevMethod = previous.paymentMethods.firstWhere(
                              (m) => m.id == selectedPaymentId,
                            );
                            final currMethod = current.paymentMethods.firstWhere(
                              (m) => m.id == selectedPaymentId,
                            );
                            return prevMethod.name != currMethod.name;
                          } catch (e) {
                            return true;
                          }
                        }
                      }
                      return false;
                    },
                    builder: (context, state) {
                      String paymentMethodName = '';
                      if (state is PaymentMethodLoaded &&
                          selectedPaymentId != null) {
                        try {
                          final method = state.paymentMethods.firstWhere(
                            (m) => m.id == selectedPaymentId,
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
                      )
                          .animate()
                          .fadeIn(duration: 300.ms, delay: 300.ms)
                          .slideX(begin: -0.1, end: 0, duration: 300.ms, delay: 300.ms);
                    },
                  ),
              const SizedBox(height: 16),
              // Mostrar precio con descuento si hay promoción
              PriceBreakdownWidget(
                basePrice: basePrice,
                discountAmount: discountAmount,
                totalPrice: totalPrice,
                promotion: activePromotion,
              )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 400.ms)
                  .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: 400.ms)
                  .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 300.ms, delay: 400.ms),
            ],
          ),
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon) {
    return RepaintBoundary(
      child: Padding(
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
      ),
    );
  }
}
