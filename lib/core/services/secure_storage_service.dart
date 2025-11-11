import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

/// Service to securely store credentials for biometric authentication
class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const String _emailKey = 'biometric_email';
  static const String _passwordKey = 'biometric_password';
  static const String _biometricEnabledKey = 'biometric_enabled';

  /// Saves credentials for biometric authentication
  static Future<void> saveCredentials({
    required String email,
    required String password,
  }) async {
    try {
      // Simple encryption (XOR with a key) - in production, use proper encryption
      final encodedEmail = _encode(email);
      final encodedPassword = _encode(password);
      
      await _storage.write(key: _emailKey, value: encodedEmail);
      await _storage.write(key: _passwordKey, value: encodedPassword);
      await _storage.write(key: _biometricEnabledKey, value: 'true');
    } catch (e) {
      throw Exception('Error saving credentials: $e');
    }
  }

  /// Gets saved email
  static Future<String?> getEmail() async {
    try {
      final encodedEmail = await _storage.read(key: _emailKey);
      if (encodedEmail == null) return null;
      return _decode(encodedEmail);
    } catch (e) {
      return null;
    }
  }

  /// Gets saved password
  static Future<String?> getPassword() async {
    try {
      final encodedPassword = await _storage.read(key: _passwordKey);
      if (encodedPassword == null) return null;
      return _decode(encodedPassword);
    } catch (e) {
      return null;
    }
  }

  /// Gets saved credentials
  static Future<Map<String, String>?> getCredentials() async {
    try {
      final email = await getEmail();
      final password = await getPassword();
      
      if (email == null || password == null) {
        return null;
      }
      
      return {
        'email': email,
        'password': password,
      };
    } catch (e) {
      return null;
    }
  }

  /// Checks if biometric authentication is enabled
  static Future<bool> isBiometricEnabled() async {
    try {
      final value = await _storage.read(key: _biometricEnabledKey);
      return value == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Removes all biometric credentials
  static Future<void> clearCredentials() async {
    try {
      await _storage.delete(key: _emailKey);
      await _storage.delete(key: _passwordKey);
      await _storage.delete(key: _biometricEnabledKey);
    } catch (e) {
      // Ignore errors on clear
    }
  }

  /// Simple encoding (XOR cipher) - replace with proper encryption in production
  static String _encode(String data) {
    final key = _getKey();
    final bytes = utf8.encode(data);
    final encoded = bytes.map((byte) => byte ^ key).toList();
    return base64Encode(encoded);
  }

  /// Simple decoding
  static String _decode(String encoded) {
    try {
      final key = _getKey();
      final decoded = base64Decode(encoded);
      final bytes = decoded.map((byte) => byte ^ key).toList();
      return utf8.decode(bytes);
    } catch (e) {
      throw Exception('Error decoding credentials');
    }
  }

  /// Gets a consistent key for encoding/decoding
  static int _getKey() {
    // In production, use a proper key management system
    // For now, use a simple key based on a constant
    const keyString = 'barber_app_biometric_key_2024';
    return keyString.hashCode & 0xFF;
  }
}

