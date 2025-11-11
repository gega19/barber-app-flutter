import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AuthFormCard extends StatelessWidget {
  final Widget child;

  const AuthFormCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGold,
          width: 2,
        ),
      ),
      child: child,
    );
  }
}

