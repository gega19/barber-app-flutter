import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../common/app_text_field.dart';

class HomeHeader extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  const HomeHeader({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Logo
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGold.withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/logo.png',
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: const BoxDecoration(
                          color: AppColors.primaryGold,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.content_cut,
                          size: 28,
                          color: AppColors.textDark,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Texto de saludo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, authState) {
                        final userName = authState is AuthAuthenticated
                            ? authState.user.name.split(' ').first
                            : 'Usuario';

                        return Text(
                          'Hola, $userName',
                          style: const TextStyle(
                            color: AppColors.primaryGold,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '¿Listo para un nuevo look?',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppTextField(
            hint: 'Buscar barberos, ubicación...',
            controller: searchController,
            prefixIcon: Icons.search,
            onChanged: (value) => onSearchChanged(value ?? ''),
          ),
        ],
      ),
    );
  }
}
