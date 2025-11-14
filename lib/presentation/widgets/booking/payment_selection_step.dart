import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/payment_method_entity.dart';
import '../../cubit/payment_method/payment_method_cubit.dart';
import 'payment_method_card_widget.dart';
import 'payment_method_card_skeleton.dart';

/// Widget para el paso de selección de método de pago
class PaymentSelectionStep extends StatelessWidget {
  final String? selectedPaymentId;
  final ValueChanged<String> onPaymentSelected;

  const PaymentSelectionStep({
    super.key,
    required this.selectedPaymentId,
    required this.onPaymentSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentMethodCubit, PaymentMethodState>(
      buildWhen: (previous, current) {
        // Solo rebuild cuando cambia el tipo de estado o los métodos de pago
        if (previous.runtimeType != current.runtimeType) return true;
        if (previous is PaymentMethodLoaded && current is PaymentMethodLoaded) {
          return previous.paymentMethods.length != current.paymentMethods.length ||
              previous.paymentMethods.any((p) => !current.paymentMethods.contains(p));
        }
        return false;
      },
      builder: (context, state) {
        if (state is PaymentMethodLoading) {
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
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ...List.generate(3, (index) => const PaymentMethodCardSkeleton()),
            ],
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
                )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scale(delay: 200.ms, duration: 300.ms),
                const SizedBox(height: 16),
                Text(
                  state.message,
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
          );
        }

        final paymentMethods = state is PaymentMethodLoaded
            ? state.paymentMethods
            : <PaymentMethodEntity>[];

        if (paymentMethods.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.payment_outlined,
                  size: 64,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scale(delay: 200.ms, duration: 300.ms),
                const SizedBox(height: 16),
                Text(
                  'No hay métodos de pago disponibles',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 300.ms)
                    .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: 300.ms),
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
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ...paymentMethods.asMap().entries.map((entry) {
              final index = entry.key;
              final method = entry.value;
              return RepaintBoundary(
                key: ValueKey('payment_${method.id}'),
                child: PaymentMethodCardWidget(
                  method: method,
                  isSelected: selectedPaymentId == method.id,
                  onTap: () => onPaymentSelected(method.id),
                ),
              )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: Duration(milliseconds: index * 50))
                  .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: Duration(milliseconds: index * 50));
            }),
          ],
        );
      },
    );
  }
}
