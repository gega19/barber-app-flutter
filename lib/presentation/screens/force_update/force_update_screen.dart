import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/version_check_service.dart';

/// Pantalla que se muestra cuando se requiere una actualización obligatoria
class ForceUpdateScreen extends StatefulWidget {
  final MinimumVersionResponse minimumVersionInfo;
  final AppVersionInfo currentVersionInfo;

  const ForceUpdateScreen({
    super.key,
    required this.minimumVersionInfo,
    required this.currentVersionInfo,
  });

  @override
  State<ForceUpdateScreen> createState() => _ForceUpdateScreenState();
}

class _ForceUpdateScreenState extends State<ForceUpdateScreen> {
  bool _isUpdating = false;

  Future<void> _handleUpdate() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final updateType = widget.minimumVersionInfo.updateType ?? 'apk';
      String? urlToLaunch;

      debugPrint('🔄 Starting update process...');
      debugPrint('   Update Type: $updateType');

      switch (updateType) {
        case 'store':
          // Abrir Play Store o App Store
          final packageName = widget.currentVersionInfo.packageName;
          urlToLaunch =
              'https://play.google.com/store/apps/details?id=$packageName';
          debugPrint('   Opening Play Store: $urlToLaunch');
          break;

        case 'url':
          // Usar URL personalizada
          urlToLaunch = widget.minimumVersionInfo.updateUrl;
          debugPrint('   Using custom URL: $urlToLaunch');
          break;

        case 'apk':
        default:
          // Descargar APK directamente
          urlToLaunch = widget.minimumVersionInfo.apkUrl;
          debugPrint('   Using APK URL: $urlToLaunch');
          break;
      }

      if (urlToLaunch != null && urlToLaunch.isNotEmpty) {
        // Si la URL del APK es relativa, construir la URL completa
        String finalUrl = urlToLaunch;
        if (updateType == 'apk' &&
            !urlToLaunch.startsWith('http://') &&
            !urlToLaunch.startsWith('https://')) {
          finalUrl = '${AppConstants.baseUrl}$urlToLaunch';
          debugPrint('   Constructed full APK URL: $finalUrl');
        }

        final uri = Uri.parse(finalUrl);
        debugPrint('   Launching URL: $uri');

        bool launched = false;

        // Intentar múltiples modos de lanzamiento
        // 1. Intentar con externalApplication (app externa/navegador)
        try {
          debugPrint('   Attempting LaunchMode.externalApplication...');
          launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (launched) {
            debugPrint('✅ URL launched successfully with externalApplication');
            return; // Éxito, salir
          }
        } catch (e) {
          debugPrint('   ⚠️ externalApplication failed: $e');
        }

        // 2. Intentar con platformDefault
        try {
          debugPrint('   Attempting LaunchMode.platformDefault...');
          launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
          if (launched) {
            debugPrint('✅ URL launched successfully with platformDefault');
            return; // Éxito, salir
          }
        } catch (e) {
          debugPrint('   ⚠️ platformDefault failed: $e');
        }

        // 3. Intentar con inAppWebView como último recurso
        try {
          debugPrint('   Attempting LaunchMode.inAppWebView...');
          launched = await launchUrl(uri, mode: LaunchMode.inAppWebView);
          if (launched) {
            debugPrint('✅ URL launched successfully with inAppWebView');
            return; // Éxito, salir
          }
        } catch (e) {
          debugPrint('   ⚠️ inAppWebView failed: $e');
        }

        // Si todos los intentos fallan, mostrar error con opción de copiar
        debugPrint('❌ All launch modes failed for URL: $finalUrl');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'No se pudo abrir la URL. Puedes copiarla y abrirla manualmente.',
              ),
              backgroundColor: AppColors.warning,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Copiar URL',
                textColor: Colors.white,
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: finalUrl));
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('URL copiada al portapapeles'),
                        backgroundColor: AppColors.success,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ),
          );
        }
      } else {
        debugPrint('❌ No URL available for update type: $updateType');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No se encontró URL de actualización'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error during update: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar la actualización: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final updateType = widget.minimumVersionInfo.updateType ?? 'apk';
    final updateTypeText = updateType == 'store'
        ? 'Tienda de Aplicaciones'
        : updateType == 'url'
        ? 'URL Personalizada'
        : 'Descarga Directa';

    return WillPopScope(
      onWillPop: () async {
        // Prevenir que el usuario cierre la pantalla si la actualización es obligatoria
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono de actualización
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.system_update,
                    size: 64,
                    color: AppColors.primaryGold,
                  ),
                ),
                const SizedBox(height: 32),

                // Título
                const Text(
                  'Actualización Requerida',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Mensaje
                Text(
                  'Tu versión de la aplicación está desactualizada. Por favor, actualiza a la versión más reciente para continuar usando la app.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Información de versiones
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildVersionInfo(
                        'Versión Actual',
                        'v${widget.currentVersionInfo.version} (${widget.currentVersionInfo.versionCode})',
                        AppColors.textSecondary,
                      ),
                      const SizedBox(height: 12),
                      _buildVersionInfo(
                        'Versión Requerida',
                        'v${widget.minimumVersionInfo.currentVersion} (${widget.minimumVersionInfo.currentVersionCode})',
                        AppColors.primaryGold,
                      ),
                      const SizedBox(height: 12),
                      _buildVersionInfo(
                        'Tipo de Actualización',
                        updateTypeText,
                        AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Botón de actualizar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isUpdating ? null : _handleUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      foregroundColor: AppColors.backgroundDark,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isUpdating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.backgroundDark,
                              ),
                            ),
                          )
                        : const Text(
                            'Actualizar Ahora',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Información adicional
                Text(
                  'Esta actualización es obligatoria para continuar usando la aplicación.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVersionInfo(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
