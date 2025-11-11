import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: AppColors.primaryGold,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.content_cut,
            size: 40,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          AppConstants.appName,
          style: const TextStyle(
            color: AppColors.primaryGold,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppConstants.appTagline,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

