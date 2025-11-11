import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

/// Service to handle biometric authentication
class BiometricAuth {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  /// Checks if biometric authentication is available
  static Future<bool> isAvailable() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable || isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  /// Gets available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Authenticates the user using biometrics
  static Future<bool> authenticate({
    String reason = 'Autentícate para continuar',
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
        ),
      );
      return didAuthenticate;
    } on PlatformException {
      // Handle platform-specific errors
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Gets the descriptive message for the available biometric type
  static Future<String> getBiometricTypeName() async {
    final availableBiometrics = await getAvailableBiometrics();
    if (availableBiometrics.isEmpty) {
      return 'Biometría';
    }
    
    if (availableBiometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Huella dactilar';
    } else if (availableBiometrics.contains(BiometricType.iris)) {
      return 'Iris';
    } else if (availableBiometrics.contains(BiometricType.strong)) {
      return 'Autenticación fuerte';
    } else if (availableBiometrics.contains(BiometricType.weak)) {
      return 'Autenticación débil';
    }
    return 'Biometría';
  }
}

