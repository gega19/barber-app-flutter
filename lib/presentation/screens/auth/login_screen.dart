import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/biometric_auth.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/injection/injection.dart' as injection;
import '../../../data/datasources/local/local_storage.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/auth/password_field.dart';
import '../../widgets/auth/auth_header.dart';
import '../../widgets/auth/auth_form_card.dart';
import '../../widgets/auth/remember_me_checkbox.dart';

/// Authentication screen (Login and Register)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isLogin = true;
  bool _rememberMe = false;
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  bool _acceptTerms = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    _checkBiometricStatus();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    final localStorage = injection.sl<LocalStorage>();
    final rememberMe = await localStorage.getRememberMe();
    final savedEmail = await localStorage.getSavedEmail();

    setState(() {
      _rememberMe = rememberMe;
      if (rememberMe && savedEmail != null) {
        _emailController.text = savedEmail;
      }
    });
  }

  /// Checks if biometric authentication is available and enabled
  Future<void> _checkBiometricStatus() async {
    final isAvailable = await BiometricAuth.isAvailable();
    final isEnabled = await SecureStorageService.isBiometricEnabled();

    setState(() {
      _biometricAvailable = isAvailable;
      _biometricEnabled = isEnabled;
    });
  }

  /// Handles the toggle between login and register
  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
      // Clear fields when switching mode
      _nameController.clear();
      _passwordController.clear();
      if (!_rememberMe) {
        _emailController.clear();
      }
      // Reset form validation
      _formKey.currentState?.reset();
      if (_isLogin) {
        _acceptTerms = false;
      }
    });
  }

  /// Handles form submission
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Close keyboard when submitting
    FocusScope.of(context).unfocus();

    final authCubit = context.read<AuthCubit>();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (!_isLogin && !_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los Términos y Condiciones.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Save email if "Remember me" is enabled
    final localStorage = injection.sl<LocalStorage>();
    if (_rememberMe) {
      await localStorage.saveEmail(email);
      await localStorage.saveRememberMe(true);
    } else {
      await localStorage.saveRememberMe(false);
      await localStorage.saveEmail('');
    }

    if (_isLogin) {
      authCubit.login(
        email: email,
        password: password,
      );
    } else {
      authCubit.register(
        name: _nameController.text.trim(),
        email: email,
        password: password,
      );
    }
  }

  /// Handles biometric authentication and automatic login
  Future<void> _handleBiometricAuth() async {
    if (!_biometricEnabled) {
      return;
    }

    // Authenticate with biometrics
    final authenticated = await BiometricAuth.authenticate(
      reason: 'Autentícate para iniciar sesión',
    );

    if (!authenticated || !mounted) {
      return;
    }

    // Get saved credentials
    final credentials = await SecureStorageService.getCredentials();
    
    if (credentials == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se encontraron credenciales guardadas'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    // Auto-login with saved credentials
    final authCubit = context.read<AuthCubit>();
    authCubit.login(
      email: credentials['email']!,
      password: credentials['password']!,
    );
  }

  /// Moves focus to the next field
  void _moveToNextField(FocusNode nextFocus) {
    FocusScope.of(context).requestFocus(nextFocus);
  }

  /// Abre la URL de términos de servicio en el navegador
  Future<void> _openTermsOfService() async {
    final url = Uri.parse('${AppConstants.landingUrl}/terms-of-service');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir los términos de servicio'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Abre la URL de política de privacidad en el navegador
  Future<void> _openPrivacyPolicy() async {
    final url = Uri.parse('${AppConstants.landingUrl}/privacy-policy');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir la política de privacidad'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/home');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
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
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              child: Text(
                                _isLogin ? 'Iniciar Sesión' : 'Crear Cuenta',
                                key: ValueKey<String>(_isLogin ? 'login' : 'register'),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Name field (only in register) with smooth animation
                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: !_isLogin
                                  ? Column(
                                      children: [
                                        AppTextField(
                                          key: const ValueKey('name_field'),
                                          label: 'Nombre',
                                          hint: 'Tu nombre completo',
                                          controller: _nameController,
                                          prefixIcon: Icons.person,
                                          focusNode: _nameFocusNode,
                                          textInputAction: TextInputAction.next,
                                          onFieldSubmitted: (_) => _moveToNextField(_emailFocusNode),
                                          autofillHints: AutofillHints.name,
                                          validator: Validators.validateName,
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                    )
                                  : const SizedBox.shrink(key: ValueKey('name_empty')),
                            ),
                            // Email field
                            AppTextField(
                              label: 'Email',
                              hint: 'tu@email.com',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.email,
                              focusNode: _emailFocusNode,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) => _moveToNextField(
                                _isLogin ? _passwordFocusNode : _passwordFocusNode,
                              ),
                              autofillHints: AutofillHints.email,
                              validator: Validators.validateEmail,
                            ),
                            const SizedBox(height: 16),
                            // Password field
                            PasswordField(
                              label: 'Contraseña',
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _handleSubmit(),
                              validator: (value) => Validators.validatePassword(
                                value,
                                isRegister: !_isLogin,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Remember me / Terms block with smooth animation
                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: _isLogin
                                  ? Column(
                                      key: const ValueKey('remember_block'),
                                      children: [
                                        RememberMeCheckbox(
                                          value: _rememberMe,
                                          onChanged: (value) {
                                            setState(() {
                                              _rememberMe = value ?? false;
                                            });
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                    )
                                  : Column(
                                      key: const ValueKey('terms_block'),
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: Checkbox(
                                                value: _acceptTerms,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _acceptTerms = value ?? false;
                                                  });
                                                },
                                                activeColor: AppColors.primaryGold,
                                                checkColor: AppColors.textDark,
                                                side: BorderSide(
                                                  color: AppColors.borderGold,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: RichText(
                                                text: TextSpan(
                                                  style: const TextStyle(
                                                    color: AppColors.textSecondary,
                                                    fontSize: 12,
                                                  ),
                                                  children: [
                                                    const TextSpan(text: 'Acepto los '),
                                                    TextSpan(
                                                      text: 'Términos y Condiciones',
                                                      style: const TextStyle(
                                                        color: AppColors.primaryGold,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                      recognizer: TapGestureRecognizer()
                                                        ..onTap = _openTermsOfService,
                                                    ),
                                                    const TextSpan(text: ' y la '),
                                                    TextSpan(
                                                      text: 'Política de Privacidad',
                                                      style: const TextStyle(
                                                        color: AppColors.primaryGold,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                      recognizer: TapGestureRecognizer()
                                                        ..onTap = _openPrivacyPolicy,
                                                    ),
                                                    const TextSpan(text: '.'),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                    ),
                            ),
                            // Submit button and biometric button
                            BlocBuilder<AuthCubit, AuthState>(
                              builder: (context, state) {
                                final isLoading = state is AuthLoading;
                                
                                return Row(
                                  children: [
                                    if (_isLogin && _biometricEnabled && _biometricAvailable) ...[
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: isLoading ? null : _handleBiometricAuth,
                                          icon: const Icon(
                                            Icons.fingerprint,
                                            color: AppColors.primaryGold,
                                          ),
                                          label: const Text(
                                            'Huella',
                                            style: TextStyle(
                                              color: AppColors.primaryGold,
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                              color: AppColors.primaryGold,
                                              width: 1.5,
                                            ),
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                    ],
                                    Expanded(
                                      flex: _isLogin && _biometricEnabled && _biometricAvailable ? 2 : 1,
                                      child: AppButton(
                                        text: _isLogin ? 'Entrar' : 'Registrarse',
                                        onPressed: isLoading ? null : _handleSubmit,
                                        isLoading: isLoading,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            // Button to toggle between login and register
                            TextButton(
                              onPressed: _toggleAuthMode,
                              child: Text(
                                _isLogin
                                    ? '¿No tienes cuenta? Regístrate'
                                    : '¿Ya tienes cuenta? Inicia sesión',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
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
