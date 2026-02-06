import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/user_entity.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../common/app_card.dart';
import '../common/app_button.dart';
import 'verify_phone_sheet.dart';

/// Muestra el estado de verificación de teléfono y permite iniciar el flujo de verificación.
class ProfilePhoneVerificationWidget extends StatelessWidget {
  final UserEntity user;
  final VoidCallback? onVerificationComplete;

  const ProfilePhoneVerificationWidget({
    super.key,
    required this.user,
    this.onVerificationComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isVerified = user.phoneVerified;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isVerified
                    ? AppColors.success.withValues(alpha: 0.15)
                    : AppColors.warning.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isVerified ? Icons.verified : Icons.phone_android,
                color: isVerified ? AppColors.success : AppColors.warning,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isVerified ? 'Teléfono verificado' : 'No estás verificado',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isVerified
                        ? 'Tu número de teléfono ha sido verificado.'
                        : 'Verifica tu teléfono para mayor autenticidad.',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (!isVerified)
              AppButton(
                text: 'Verificar',
                onPressed: () => _openVerifySheet(context),
                type: ButtonType.outline,
                icon: Icons.verified_user,
              ),
          ],
        ),
      ),
    );
  }

  void _openVerifySheet(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: authCubit,
        child: VerifyPhoneSheet(
          initialPhone: user.phone,
          onSuccess: () {
            Navigator.of(sheetContext).pop();
            onVerificationComplete?.call();
          },
          onCancel: () => Navigator.of(sheetContext).pop(),
        ),
      ),
    );
  }
}
