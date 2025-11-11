import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

/// Fuente de datos local usando SharedPreferences
abstract class LocalStorage {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> removeToken();
  Future<void> saveRefreshToken(String token);
  Future<String?> getRefreshToken();
  Future<void> saveUserData(String userData);
  Future<String?> getUserData();
  Future<void> clearAll();
  
  // Remember me and saved email
  Future<void> saveRememberMe(bool remember);
  Future<bool> getRememberMe();
  Future<void> saveEmail(String email);
  Future<String?> getSavedEmail();
  Future<void> saveBiometricEnabled(bool enabled);
  Future<bool> getBiometricEnabled();
}

class LocalStorageImpl implements LocalStorage {
  final SharedPreferences sharedPreferences;

  LocalStorageImpl(this.sharedPreferences);

  @override
  Future<void> saveToken(String token) async {
    await sharedPreferences.setString(AppConstants.tokenKey, token);
  }

  @override
  Future<String?> getToken() async {
    return sharedPreferences.getString(AppConstants.tokenKey);
  }

  @override
  Future<void> removeToken() async {
    await sharedPreferences.remove(AppConstants.tokenKey);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await sharedPreferences.setString('${AppConstants.tokenKey}_refresh', token);
  }

  @override
  Future<String?> getRefreshToken() async {
    return sharedPreferences.getString('${AppConstants.tokenKey}_refresh');
  }

  @override
  Future<void> saveUserData(String userData) async {
    await sharedPreferences.setString(AppConstants.userKey, userData);
  }

  @override
  Future<String?> getUserData() async {
    return sharedPreferences.getString(AppConstants.userKey);
  }

  @override
  Future<void> clearAll() async {
    await sharedPreferences.clear();
  }

  @override
  Future<void> saveRememberMe(bool remember) async {
    await sharedPreferences.setBool(AppConstants.rememberMeKey, remember);
  }

  @override
  Future<bool> getRememberMe() async {
    return sharedPreferences.getBool(AppConstants.rememberMeKey) ?? false;
  }

  @override
  Future<void> saveEmail(String email) async {
    await sharedPreferences.setString(AppConstants.savedEmailKey, email);
  }

  @override
  Future<String?> getSavedEmail() async {
    return sharedPreferences.getString(AppConstants.savedEmailKey);
  }

  @override
  Future<void> saveBiometricEnabled(bool enabled) async {
    await sharedPreferences.setBool(AppConstants.biometricEnabledKey, enabled);
  }

  @override
  Future<bool> getBiometricEnabled() async {
    return sharedPreferences.getBool(AppConstants.biometricEnabledKey) ?? false;
  }
}


