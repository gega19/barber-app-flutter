import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/location_service.dart';
import '../../core/utils/location_error_messages.dart';

/// Muestra un diálogo estándar de error de ubicación.
/// Responsabilidad única: presentar el error al usuario (una sola implementación, sin duplicar).
void showLocationErrorDialog(BuildContext context, LocationErrorReason reason) {
  final message = LocationErrorMessages.getUserMessage(reason);
  final showOpenSettings = LocationErrorMessages.shouldOfferOpenSettings(
    reason,
  );

  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.backgroundCard,
      title: const Text(
        'Ubicación no disponible',
        style: TextStyle(color: AppColors.textPrimary),
      ),
      content: Text(
        message,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text(
            'Entendido',
            style: TextStyle(color: AppColors.primaryGold),
          ),
        ),
        if (showOpenSettings)
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              openAppSettings();
            },
            child: const Text(
              'Abrir configuración',
              style: TextStyle(color: AppColors.primaryGold),
            ),
          ),
      ],
    ),
  );
}
