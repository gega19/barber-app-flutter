import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../common/app_button.dart';

/// Widget para el botón de cerrar sesión
class LogoutButtonWidget extends StatelessWidget {
  const LogoutButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppButton(
        text: 'Cerrar Sesión',
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.backgroundCard,
              title: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              content: const Text(
                '¿Estás seguro de que deseas cerrar sesión?',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ),
          );

          if (confirmed == true) {
            context.read<AuthCubit>().logout();
          }
        },
        type: ButtonType.outline,
        icon: Icons.logout,
      ),
    );
  }
}

