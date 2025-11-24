import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';

/// Widget reutilizable para mostrar enlaces de redes sociales
class SocialMediaLinksWidget extends StatelessWidget {
  final String? instagramUrl;
  final String? tiktokUrl;
  final double iconSize;
  final double spacing;

  const SocialMediaLinksWidget({
    super.key,
    this.instagramUrl,
    this.tiktokUrl,
    this.iconSize = 20.0,
    this.spacing = 8.0,
  });

  /// Normaliza una URL de Instagram o TikTok
  String _normalizeUrl(String url, bool isInstagram) {
    final trimmed = url.trim();

    // Si ya es una URL completa, normalizarla
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      // Remover www. si existe para consistencia
      String normalized = trimmed;
      if (normalized.contains('www.')) {
        normalized = normalized.replaceAll('www.', '');
      }

      // Asegurar formato correcto para TikTok
      if (!isInstagram && normalized.contains('tiktok.com')) {
        // TikTok debe tener @ en el path
        if (!normalized.contains('/@')) {
          // Si tiene /user/ o solo /username, convertir a /@username
          final uri = Uri.parse(normalized);
          final path = uri.path;
          if (path.isNotEmpty && !path.startsWith('/@')) {
            final username = path.replaceAll('/', '').replaceAll('@', '');
            return 'https://tiktok.com/@$username';
          }
        }
      }

      return normalized;
    }

    // Si empieza con @, convertir a URL
    if (trimmed.startsWith('@')) {
      final username = trimmed.substring(1);
      if (isInstagram) {
        return 'https://instagram.com/$username';
      } else {
        return 'https://tiktok.com/@$username';
      }
    }

    // Si contiene el dominio, agregar https:// y normalizar
    if (trimmed.contains('instagram.com') || trimmed.contains('tiktok.com')) {
      String normalized = 'https://$trimmed';
      // Remover www.
      normalized = normalized.replaceAll('www.', '');
      return normalized;
    }

    // Si no tiene @ ni http, asumir que es un username
    if (isInstagram) {
      return 'https://instagram.com/$trimmed';
    } else {
      return 'https://tiktok.com/@$trimmed';
    }
  }

  /// Abre una URL en el navegador o app nativa
  Future<void> _launchUrl(
    String url,
    bool isInstagram,
    BuildContext context,
  ) async {
    try {
      // Normalizar la URL primero
      final normalizedUrl = _normalizeUrl(url, isInstagram);
      final uri = Uri.parse(normalizedUrl);

      // Intentar abrir con la app nativa primero (si está instalada)
      try {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) {
          return; // Éxito, salir
        }
      } catch (e) {
        debugPrint('Error al abrir con app nativa: $e');
      }

      // Si no se pudo abrir con app nativa, intentar con el navegador
      try {
        final launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
        if (launched) {
          return; // Éxito, salir
        }
      } catch (e) {
        debugPrint('Error al abrir con navegador: $e');
      }

      // Si ambos fallan, intentar con inAppWebView como último recurso
      try {
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
      } catch (e) {
        // Si todo falla, mostrar error
        debugPrint('Error al abrir URL: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'No se pudo abrir el enlace. Intenta copiar la URL: $normalizedUrl',
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Copiar',
                textColor: Colors.white,
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: normalizedUrl));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('URL copiada al portapapeles'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error general al abrir URL: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir el enlace: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSocialMedia = instagramUrl != null || tiktokUrl != null;

    if (!hasSocialMedia) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (instagramUrl != null)
          _SocialMediaButton(
            iconPath: 'assets/icons/instagram.svg',
            label: 'Instagram',
            url: instagramUrl!,
            color: const Color(0xFFE4405F),
            iconSize: iconSize,
            onTap: () => _launchUrl(instagramUrl!, true, context),
          ),
        if (instagramUrl != null && tiktokUrl != null) SizedBox(width: spacing),
        if (tiktokUrl != null)
          _SocialMediaButton(
            iconPath: 'assets/icons/tiktok.svg',
            label: 'TikTok',
            url: tiktokUrl!,
            iconSize: iconSize,
            onTap: () => _launchUrl(tiktokUrl!, false, context),
          ),
      ],
    );
  }
}

class _SocialMediaButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final String url;
  final Color? color;
  final double iconSize;
  final VoidCallback onTap;

  const _SocialMediaButton({
    required this.iconPath,
    required this.label,
    required this.url,
    required this.iconSize,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          constraints: const BoxConstraints(minWidth: 0),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.backgroundCardDark,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color.fromARGB(124, 228, 64, 94),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono SVG
              SizedBox(
                width: iconSize,
                height: iconSize,
                child: SvgPicture.asset(
                  iconPath,
                  width: iconSize,
                  height: iconSize,
                  fit: BoxFit.contain,
                  colorFilter: color != null
                      ? ColorFilter.mode(color!, BlendMode.srcIn)
                      : null,
                  placeholderBuilder: (context) => Icon(
                    iconPath.contains('instagram')
                        ? Icons.camera_alt
                        : Icons.music_note,
                    color: color,
                    size: iconSize,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
