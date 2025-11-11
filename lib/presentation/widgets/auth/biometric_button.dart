import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class BiometricButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String biometricTypeName;

  const BiometricButton({
    super.key,
    required this.onPressed,
    required this.biometricTypeName,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(
        Icons.fingerprint,
        color: AppColors.primaryGold,
        size: 24,
      ),
      label: Text(
        'Usar $biometricTypeName',
        style: const TextStyle(
          color: AppColors.primaryGold,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.primaryGold, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

