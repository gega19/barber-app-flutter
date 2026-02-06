import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

/// Service to handle biometric authentication
class BiometricAuth {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  /// Checks if biometric authentication is available
  static Future<bool> isAvailable() async {
    try {
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheckBiometrics || isDeviceSupported;
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
    bool biometricOnly = false,
    bool persistAcrossBackgrounding = true,
  }) async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: biometricOnly,
        persistAcrossBackgrounding: persistAcrossBackgrounding,
      );
      return didAuthenticate;
    } on PlatformException catch (e) {
      // Handle platform-specific errors
      print('PlatformException: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      // Handle any other errors
      print('Error in authenticate: $e');
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
