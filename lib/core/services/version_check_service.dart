import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

/// Modelo para la respuesta del endpoint de versión mínima
class MinimumVersionResponse {
  final int? minimumVersionCode;
  final int currentVersionCode;
  final String currentVersion;
  final String? updateUrl;
  final String? updateType; // 'store' | 'url' | 'apk'
  final bool forceUpdate;
  final String? apkUrl;

  MinimumVersionResponse({
    this.minimumVersionCode,
    required this.currentVersionCode,
    required this.currentVersion,
    this.updateUrl,
    this.updateType,
    required this.forceUpdate,
    this.apkUrl,
  });

  factory MinimumVersionResponse.fromJson(Map<String, dynamic> json) {
    return MinimumVersionResponse(
      minimumVersionCode: json['minimumVersionCode'] as int?,
      currentVersionCode: json['currentVersionCode'] as int,
      currentVersion: json['currentVersion'] as String,
      updateUrl: json['updateUrl'] as String?,
      updateType: json['updateType'] as String?,
      forceUpdate: json['forceUpdate'] as bool? ?? false,
      apkUrl: json['apkUrl'] as String?,
    );
  }

  @override
  String toString() {
    return 'MinimumVersionResponse(minimumVersionCode: $minimumVersionCode, currentVersionCode: $currentVersionCode, currentVersion: $currentVersion, updateType: $updateType, forceUpdate: $forceUpdate)';
  }
}

/// Modelo para la información de la versión actual de la app
class AppVersionInfo {
  final String version; // Versión semántica: "1.0.0"
  final int versionCode; // Código de versión incremental
  final String buildNumber;
  final String packageName;
  final String appName;

  AppVersionInfo({
    required this.version,
    required this.versionCode,
    required this.buildNumber,
    required this.packageName,
    required this.appName,
  });

  @override
  String toString() {
    return 'AppVersionInfo(version: $version, versionCode: $versionCode, buildNumber: $buildNumber, packageName: $packageName, appName: $appName)';
  }
}

/// Resultado de la verificación de versión
enum VersionCheckResult {
  upToDate, // La app está actualizada
  updateAvailable, // Hay una actualización disponible pero no es obligatoria
  updateRequired, // La actualización es obligatoria
  error, // Error al verificar
}

/// Servicio para verificar la versión mínima requerida de la app
class VersionCheckService {
  final Dio _dio;
  PackageInfo? _packageInfo;
  AppVersionInfo? _currentVersionInfo;

  VersionCheckService(this._dio);

  /// Inicializa el servicio obteniendo la información de la app
  Future<void> initialize() async {
    try {
      _packageInfo = await PackageInfo.fromPlatform();

      // Extraer versionCode del buildNumber (formato: "1.0.0+3" -> versionCode = 3)
      final buildNumber = _packageInfo!.buildNumber;
      final versionCode = int.tryParse(buildNumber) ?? 0;

      _currentVersionInfo = AppVersionInfo(
        version: _packageInfo!.version,
        versionCode: versionCode,
        buildNumber: buildNumber,
        packageName: _packageInfo!.packageName,
        appName: _packageInfo!.appName,
      );

      debugPrint('📱 VersionCheckService initialized:');
      debugPrint('   App Name: ${_currentVersionInfo!.appName}');
      debugPrint('   Version: ${_currentVersionInfo!.version}');
      debugPrint('   Version Code: ${_currentVersionInfo!.versionCode}');
      debugPrint('   Build Number: ${_currentVersionInfo!.buildNumber}');
      debugPrint('   Package: ${_currentVersionInfo!.packageName}');
    } catch (e) {
      debugPrint('❌ Error initializing VersionCheckService: $e');
      rethrow;
    }
  }

  /// Obtiene la información de la versión actual de la app
  AppVersionInfo? getCurrentVersionInfo() {
    return _currentVersionInfo;
  }

  /// Verifica si la app necesita actualizarse
  ///
  /// Retorna:
  /// - `VersionCheckResult.upToDate`: La app está actualizada
  /// - `VersionCheckResult.updateAvailable`: Hay una actualización disponible pero no es obligatoria
  /// - `VersionCheckResult.updateRequired`: La actualización es obligatoria
  /// - `VersionCheckResult.error`: Error al verificar
  Future<VersionCheckResult> checkVersion() async {
    if (_currentVersionInfo == null) {
      debugPrint(
        '⚠️ VersionCheckService not initialized. Calling initialize()...',
      );
      await initialize();
    }

    try {
      debugPrint('🔍 Checking app version...');
      debugPrint(
        '   Current Version Code: ${_currentVersionInfo!.versionCode}',
      );
      debugPrint('   Current Version: ${_currentVersionInfo!.version}');

      final response = await _dio.get<Map<String, dynamic>>(
        '${AppConstants.baseUrl}/api/app/minimum-version',
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!['data'] as Map<String, dynamic>;
        final minimumVersion = MinimumVersionResponse.fromJson(data);

        debugPrint('📊 Version check response:');
        debugPrint(
          '   Minimum Version Code: ${minimumVersion.minimumVersionCode ?? "Not set"}',
        );
        debugPrint(
          '   Current Server Version Code: ${minimumVersion.currentVersionCode}',
        );
        debugPrint(
          '   Current Server Version: ${minimumVersion.currentVersion}',
        );
        debugPrint('   Update Type: ${minimumVersion.updateType ?? "Not set"}');
        debugPrint('   Force Update: ${minimumVersion.forceUpdate}');
        debugPrint('   Update URL: ${minimumVersion.updateUrl ?? "Not set"}');
        debugPrint('   APK URL: ${minimumVersion.apkUrl ?? "Not set"}');

        // Si no hay versión mínima configurada, la app está actualizada
        if (minimumVersion.minimumVersionCode == null) {
          debugPrint('✅ No minimum version set. App is up to date.');
          return VersionCheckResult.upToDate;
        }

        final currentVersionCode = _currentVersionInfo!.versionCode;
        final minimumVersionCode = minimumVersion.minimumVersionCode!;

        debugPrint('🔍 Comparing versions:');
        debugPrint('   Current: $currentVersionCode');
        debugPrint('   Minimum: $minimumVersionCode');

        // Si la versión actual es menor que la mínima requerida
        if (currentVersionCode < minimumVersionCode) {
          debugPrint('⚠️ App version is below minimum required version!');
          debugPrint(
            '   Current: $currentVersionCode < Minimum: $minimumVersionCode',
          );

          if (minimumVersion.forceUpdate) {
            debugPrint('🚨 FORCE UPDATE REQUIRED - App will be blocked');
            return VersionCheckResult.updateRequired;
          } else {
            debugPrint('📢 Update available (not forced)');
            return VersionCheckResult.updateAvailable;
          }
        } else {
          debugPrint('✅ App version is up to date!');
          debugPrint(
            '   Current: $currentVersionCode >= Minimum: $minimumVersionCode',
          );
          return VersionCheckResult.upToDate;
        }
      } else {
        debugPrint('❌ Invalid response from version check endpoint');
        debugPrint('   Status Code: ${response.statusCode}');
        debugPrint('   Data: ${response.data}');
        return VersionCheckResult.error;
      }
    } catch (e) {
      debugPrint('❌ Error checking version: $e');
      if (e is DioException) {
        debugPrint('   DioException Type: ${e.type}');
        debugPrint('   Status Code: ${e.response?.statusCode}');
        debugPrint('   Response Data: ${e.response?.data}');
      }
      return VersionCheckResult.error;
    }
  }

  /// Obtiene la información de la versión mínima requerida
  Future<MinimumVersionResponse?> getMinimumVersionInfo() async {
    try {
      debugPrint('🔍 Fetching minimum version info...');

      final response = await _dio.get<Map<String, dynamic>>(
        '${AppConstants.baseUrl}/api/app/minimum-version',
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!['data'] as Map<String, dynamic>;
        final minimumVersion = MinimumVersionResponse.fromJson(data);

        debugPrint('📊 Minimum version info retrieved:');
        debugPrint('   ${minimumVersion.toString()}');

        return minimumVersion;
      } else {
        debugPrint('❌ Invalid response from version check endpoint');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error fetching minimum version info: $e');
      return null;
    }
  }

  /// Verifica la versión y retorna información detallada
  Future<Map<String, dynamic>> checkVersionDetailed() async {
    if (_currentVersionInfo == null) {
      await initialize();
    }

    final result = await checkVersion();
    final minimumVersionInfo = await getMinimumVersionInfo();

    final details = {
      'result': result,
      'currentVersion': _currentVersionInfo,
      'minimumVersion': minimumVersionInfo,
      'needsUpdate':
          result == VersionCheckResult.updateRequired ||
          result == VersionCheckResult.updateAvailable,
      'updateRequired': result == VersionCheckResult.updateRequired,
    };

    debugPrint('📋 Version check details:');
    debugPrint('   Result: $result');
    debugPrint('   Needs Update: ${details['needsUpdate']}');
    debugPrint('   Update Required: ${details['updateRequired']}');

    return details;
  }
}
