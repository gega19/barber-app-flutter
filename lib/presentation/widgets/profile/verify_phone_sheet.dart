import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/phone_utils.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../common/app_button.dart';
import '../common/app_text_field.dart';

enum _VerifyStep { phone, code }

class VerifyPhoneSheet extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  final String? initialPhone;

  const VerifyPhoneSheet({
    super.key,
    required this.onSuccess,
    required this.onCancel,
    this.initialPhone,
  });

  @override
  State<VerifyPhoneSheet> createState() => _VerifyPhoneSheetState();
}

class _VerifyPhoneSheetState extends State<VerifyPhoneSheet> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  _VerifyStep _step = _VerifyStep.phone;
  String _phone = '';
  bool _isSending = false;
  bool _isVerifying = false;
  String? _errorMessage;
  int _resendCooldownSeconds = 0;
  Timer? _cooldownTimer;
  static const int _cooldownAfterSendSeconds = 60;

  @override
  void initState() {
    super.initState();
    if (widget.initialPhone != null && widget.initialPhone!.trim().isNotEmpty) {
      _phoneController.text = widget.initialPhone!.trim();
    }
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _startCooldown(int seconds) {
    _cooldownTimer?.cancel();
    setState(() => _resendCooldownSeconds = seconds);
    if (seconds <= 0) return;
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _resendCooldownSeconds = (_resendCooldownSeconds - 1).clamp(0, 999);
        if (_resendCooldownSeconds <= 0) _cooldownTimer?.cancel();
      });
    });
  }

  String get _normalizedPhone => normalizePhoneToE164(_phoneController.text);

  Future<void> _sendCode() async {
    _phone = _normalizedPhone;
    final digitsOnly = _phone.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 10) {
      setState(
        () => _errorMessage = 'Ingresa un número válido (ej: +58 412 1234567)',
      );
      return;
    }
    setState(() {
      _errorMessage = null;
      _isSending = true;
    });

    final authCubit = context.read<AuthCubit>();
    final result = await authCubit.sendPhoneVerificationCode(_phone);
    if (!mounted) return;
    final success = result.$1;
    final errorMessage = result.$2;
    final retryAfterSeconds = result.$3;
    setState(() => _isSending = false);
    if (success) {
      setState(() {
        _step = _VerifyStep.code;
        _errorMessage = null;
      });
      _startCooldown(_cooldownAfterSendSeconds);
    } else {
      if (retryAfterSeconds != null && retryAfterSeconds > 0) {
        _startCooldown(retryAfterSeconds);
      }
      setState(
        () => _errorMessage = errorMessage != null && errorMessage.isNotEmpty
            ? errorMessage
            : 'No se pudo enviar el código. Intenta de nuevo.',
      );
    }
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _errorMessage = 'Ingresa el código que recibiste por SMS');
      return;
    }
    setState(() {
      _errorMessage = null;
      _isVerifying = true;
    });

    final authCubit = context.read<AuthCubit>();
    final (success, errorMessage) = await authCubit.confirmPhoneVerification(
      _phone,
      code,
    );
    if (!mounted) return;
    setState(() => _isVerifying = false);
    if (success) {
      widget.onSuccess();
    } else {
      setState(
        () => _errorMessage = errorMessage?.isNotEmpty == true
            ? errorMessage
            : 'Código inválido o expirado. Intenta de nuevo.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _step == _VerifyStep.phone
                  ? 'Verificar teléfono'
                  : 'Código de verificación',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _step == _VerifyStep.phone
                  ? 'Ingresa tu número en formato internacional (ej: +58 412 1234567)'
                  : 'Ingresa el código de 6 dígitos que enviamos al $_phone',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            if (_step == _VerifyStep.phone) ...[
              AppTextField(
                label: 'Número de teléfono',
                hint: '+58 412 1234567',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone,
                onChanged: (_) => setState(() => _errorMessage = null),
              ),
            ] else ...[
              AppTextField(
                label: 'Código SMS',
                hint: '123456',
                controller: _codeController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.sms,
                onChanged: (_) => setState(() => _errorMessage = null),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.textSecondary.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Si no aparece el SMS, revisa la carpeta de Spam o Mensajes desconocidos.',
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.9),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.error, fontSize: 13),
              ),
            ],
            const SizedBox(height: 24),
            if (_step == _VerifyStep.phone)
              AppButton(
                text: 'Enviar código',
                onPressed: _isSending ? null : _sendCode,
                isLoading: _isSending,
                icon: Icons.send,
              )
            else ...[
              AppButton(
                text: 'Verificar',
                onPressed: _isVerifying ? null : _verifyCode,
                isLoading: _isVerifying,
                icon: Icons.verified,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed:
                        (_isSending ||
                            _isVerifying ||
                            _resendCooldownSeconds > 0)
                        ? null
                        : _sendCode,
                    child: Text(
                      _resendCooldownSeconds > 0
                          ? 'Reenviar código en ${_resendCooldownSeconds}s'
                          : 'Reenviar código',
                      style: TextStyle(
                        color: _resendCooldownSeconds > 0
                            ? AppColors.textSecondary
                            : AppColors.primaryGold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _isSending || _isVerifying
                        ? null
                        : () {
                            setState(() {
                              _step = _VerifyStep.phone;
                              _errorMessage = null;
                              _codeController.clear();
                              _resendCooldownSeconds = 0;
                              _cooldownTimer?.cancel();
                            });
                          },
                    child: const Text(
                      'Cambiar número',
                      style: TextStyle(color: AppColors.primaryGold),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            TextButton(
              onPressed: _isSending || _isVerifying ? null : widget.onCancel,
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
