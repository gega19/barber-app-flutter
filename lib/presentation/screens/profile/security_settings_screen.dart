import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/biometric_auth.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../../widgets/common/app_card.dart';

/// Security settings screen for biometric authentication
class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  bool _isLoading = true;
  bool _isToggling = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    final isAvailable = await BiometricAuth.isAvailable();
    final isEnabled = await SecureStorageService.isBiometricEnabled();

    setState(() {
      _biometricAvailable = isAvailable;
      _biometricEnabled = isEnabled;
      _isLoading = false;
    });
  }

  Future<void> _toggleBiometricAuth(bool value) async {
    if (!_biometricAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La autenticación biométrica no está disponible en este dispositivo'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isToggling = true;
    });

    if (value) {
      // Activating biometric authentication
      await _activateBiometricAuth();
    } else {
      // Deactivating biometric authentication
      await _deactivateBiometricAuth();
    }

    setState(() {
      _isToggling = false;
    });
  }

  Future<void> _activateBiometricAuth() async {
    // Get current user credentials
    final authCubit = context.read<AuthCubit>();
    final authState = authCubit.state;

    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes estar autenticado para activar la biometría'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final user = authState.user;

    // Request current password from user
    final password = await _requestPassword();
    if (password == null || password.isEmpty) {
      return; // User cancelled
    }

    // Verify password by attempting login (we need to verify it's correct)
    // Note: In production, you might want to add a verify password endpoint
    // For now, we'll use the current authenticated session and trust the password
    // Show biometric confirmation modal
    final authenticated = await _showBiometricConfirmation();
    
    if (!authenticated) {
      return; // User cancelled or failed biometric
    }

    // Save credentials securely
    try {
      await SecureStorageService.saveCredentials(
        email: user.email,
        password: password,
      );

      if (mounted) {
        setState(() {
          _biometricEnabled = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Autenticación biométrica activada correctamente'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al activar biometría: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deactivateBiometricAuth() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'Desactivar Biometría',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          '¿Estás seguro de que deseas desactivar la autenticación biométrica?',
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
              'Desactivar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await SecureStorageService.clearCredentials();
      
      if (mounted) {
        setState(() {
          _biometricEnabled = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Autenticación biométrica desactivada'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<bool> _showBiometricConfirmation() async {
    return await BiometricAuth.authenticate(
      reason: 'Confirma tu identidad para activar la autenticación biométrica',
    );
  }

  Future<String?> _requestPassword() async {
    final passwordController = TextEditingController();
    
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'Confirmar Contraseña',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            labelText: 'Contraseña',
            labelStyle: const TextStyle(color: AppColors.textSecondary),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primaryGold.withValues(alpha: 0.3)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primaryGold),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(passwordController.text),
            child: const Text(
              'Confirmar',
              style: TextStyle(color: AppColors.primaryGold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Seguridad',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.backgroundCard,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A1A),
              Color(0xFF0F0F0F),
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGold,
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGold.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.fingerprint,
                                    color: AppColors.primaryGold,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Autenticación Biométrica',
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _biometricAvailable
                                            ? 'Inicia sesión usando tu huella o Face ID'
                                            : 'No disponible en este dispositivo',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: _biometricEnabled,
                                  onChanged: _biometricAvailable && !_isToggling
                                      ? _toggleBiometricAuth
                                      : null,
                                  activeColor: AppColors.primaryGold,
                                ),
                              ],
                            ),
                            if (_isToggling)
                              const Padding(
                                padding: EdgeInsets.only(top: 16),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primaryGold,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          'Información',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: AppColors.primaryGold,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _biometricEnabled
                                        ? 'Tu autenticación biométrica está activada. Podrás iniciar sesión usando tu huella o Face ID desde la pantalla de login.'
                                        : 'Al activar la autenticación biométrica, tus credenciales se guardarán de forma segura. Podrás iniciar sesión rápidamente usando tu huella o Face ID.',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

