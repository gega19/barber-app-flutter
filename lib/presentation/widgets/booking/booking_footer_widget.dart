import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../cubit/appointment/appointment_cubit.dart';
import '../common/app_button.dart';

/// Widget para el footer del proceso de reserva con botones de navegación
class BookingFooterWidget extends StatelessWidget {
  final int currentStep;
  final VoidCallback? onBack;
  final VoidCallback? onNext;

  const BookingFooterWidget({
    super.key,
    required this.currentStep,
    this.onBack,
    this.onNext,
  });

  String _getButtonText(int step) {
    switch (step) {
      case 0:
        return 'Continuar';
      case 3:
        return 'Confirmar';
      default:
        return 'Siguiente';
    }
  }

  @override
  Widget build(BuildContext context) {
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
          if (currentStep > 0) ...[
            Expanded(
              child: AppButton(
                text: 'Volver',
                onPressed: onBack,
                type: ButtonType.outline,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: BlocBuilder<AppointmentCubit, AppointmentState>(
              buildWhen: (previous, current) {
                // Solo rebuild cuando cambia el estado de creación
                return previous is AppointmentCreating !=
                    current is AppointmentCreating;
              },
              builder: (context, state) {
                final isCreating = state is AppointmentCreating;
                return AppButton(
                  text: isCreating
                      ? 'Confirmando...'
                      : _getButtonText(currentStep),
                  onPressed: isCreating ? null : onNext,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

