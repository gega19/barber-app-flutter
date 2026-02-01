import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Widget que muestra el estado de carga para los detalles de una cita.
///
/// Este widget proporciona una experiencia de carga consistente
/// mientras se obtienen los datos de la cita desde el backend.
class AppointmentDetailLoading extends StatelessWidget {
  const AppointmentDetailLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primaryGold),
      ),
    );
  }
}
