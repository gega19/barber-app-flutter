import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../../widgets/auth/auth_form_card.dart';
import '../../widgets/auth/auth_header.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class ResetPasswordOtpScreen extends StatefulWidget {
  final String email;

  const ResetPasswordOtpScreen({super.key, required this.email});

  @override
  State<ResetPasswordOtpScreen> createState() => _ResetPasswordOtpScreenState();
}

class _ResetPasswordOtpScreenState extends State<ResetPasswordOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  int _secondsRemaining = 60;
  bool _canResend = false;
  late Timer _timer;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 60;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        setState(() {
          _canResend = true;
          _timer.cancel();
        });
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _timer.cancel();
    super.dispose();
  }

  Future<void> _handleResendCode() async {
    if (!_canResend) return;

    setState(() => _isResending = true);
    try {
      await context.read<AuthCubit>().requestPasswordResetCode(widget.email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código reenviado. Revisa tu correo.'),
          backgroundColor: AppColors.primaryGold,
        ),
      );
      _startTimer();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al reenviar código: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    // Call login with the 6-digit code as password
    context.read<AuthCubit>().login(
      email: widget.email,
      password: _codeController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
          // Note: Redirection for AuthRequiresPasswordChange handles by GoRouter
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F0F0F), Color(0xFF1A1A1A), Color(0xFF000000)],
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
                              'Ingresa el Código',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ingresa el código de 6 dígitos que enviamos a:',
                              style: TextStyle(
                                color: AppColors.textSecondary.withOpacity(0.9),
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.email,
                              style: const TextStyle(
                                color: AppColors.primaryGold,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            AppTextField(
                              label: 'Código de Recuperación',
                              hint: 'Ej. 123456',
                              controller: _codeController,
                              keyboardType: TextInputType.number,
                              prefixIcon: Icons.lock_clock,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'El código es requerido';
                                }
                                if (value.trim().length != 6) {
                                  return 'El código debe tener 6 dígitos';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            BlocBuilder<AuthCubit, AuthState>(
                              builder: (context, state) {
                                final isLoading = state is AuthLoading;
                                return Column(
                                  children: [
                                    if (_isResending)
                                      const CircularProgressIndicator(
                                        strokeWidth: 2,
                                      )
                                    else
                                      TextButton(
                                        onPressed: _canResend
                                            ? _handleResendCode
                                            : null,
                                        child: Text(
                                          _canResend
                                              ? 'Reenviar código'
                                              : 'Reenviar en ${_secondsRemaining}s',
                                          style: TextStyle(
                                            color: _canResend
                                                ? AppColors.primaryGold
                                                : AppColors.textSecondary,
                                            fontWeight: _canResend
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    AppButton(
                                      text: 'Verificar',
                                      onPressed: isLoading
                                          ? null
                                          : _handleSubmit,
                                      isLoading: isLoading,
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => context.pop(),
                              child: const Text(
                                'Volver',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
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
    );
  }
}
