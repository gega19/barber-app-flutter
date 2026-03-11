import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../../widgets/auth/auth_form_card.dart';
import '../../widgets/auth/auth_header.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/auth/password_field.dart';

class ForceChangePasswordScreen extends StatefulWidget {
  const ForceChangePasswordScreen({super.key});

  @override
  State<ForceChangePasswordScreen> createState() => _ForceChangePasswordScreenState();
}

class _ForceChangePasswordScreenState extends State<ForceChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _passwordFocusNode = FocusNode();
  final _confirmFocusNode = FocusNode();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmFocusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas no coinciden'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    context.read<AuthCubit>().changePassword(_newPasswordController.text);
  }

  void _moveToConfigFocus(FocusNode focus) {
    FocusScope.of(context).requestFocus(focus);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Evitamos volver a la app hasta que cambie la password
      body: PopScope(
        canPop: false,
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            } else if (state is AuthAuthenticated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contraseña actualizada correctamente.'),
                  backgroundColor: AppColors.primaryGold,
                ),
              );
            }
          },
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F0F0F),
                  Color(0xFF1A1A1A),
                  Color(0xFF000000),
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 24,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AuthHeader(),
                        const SizedBox(height: 48),
                        AuthFormCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Actualizar Contraseña',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Por seguridad, debes establecer una contraseña nueva y segura.',
                                style: TextStyle(
                                  color: AppColors.textSecondary.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              PasswordField(
                                label: 'Nueva Contraseña',
                                controller: _newPasswordController,
                                focusNode: _passwordFocusNode,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) => _moveToConfigFocus(_confirmFocusNode),
                                validator: (val) => Validators.validatePassword(val, isRegister: true),
                              ),
                              const SizedBox(height: 16),
                              PasswordField(
                                label: 'Confirmar Contraseña',
                                controller: _confirmPasswordController,
                                focusNode: _confirmFocusNode,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _handleSubmit(),
                                validator: (val) {
                                  if (val != _newPasswordController.text) {
                                    return 'Las contraseñas no coinciden';
                                  }
                                  return Validators.validatePassword(val, isRegister: true);
                                },
                              ),
                              const SizedBox(height: 24),
                              BlocBuilder<AuthCubit, AuthState>(
                                builder: (context, state) {
                                  final isLoading = state is AuthLoading;
                                  return AppButton(
                                    text: 'Guardar Contraseña',
                                    onPressed: isLoading ? null : _handleSubmit,
                                    isLoading: isLoading,
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () {
                                  context.read<AuthCubit>().logout();
                                },
                                child: const Text(
                                  'Cerrar sesión y salir',
                                  style: TextStyle(color: AppColors.error),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
