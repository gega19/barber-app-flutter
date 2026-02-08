import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';

/// Widget reutilizable para mostrar enlaces de redes sociales
class SocialMediaLinksWidget extends StatelessWidget {
  final String? instagramUrl;
  final String? tiktokUrl;
  final String? phoneNumber;
  final double iconSize;
  final double spacing;
  final bool showLabels;

  const SocialMediaLinksWidget({
    super.key,
    this.instagramUrl,
    this.tiktokUrl,
    this.phoneNumber,
    this.iconSize = 20.0,
    this.spacing = 8.0,
    this.showLabels = true,
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

  void _showPhoneOptions(BuildContext context, String phone) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors
          .transparent, // Transparente para usar el Container interno con borde
      isScrollControlled: true, // Para ajustar mejor el contenido
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(
              color: AppColors.primaryGold.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle (barra gris)
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Título
              Text(
                'Contactar Barbero',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 30),

              // Opciones
              _ContactOptionTile(
                icon: SvgPicture.asset(
                  'assets/icons/whatsapp.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  // Fallback to icon if SVG fails or is missing
                  placeholderBuilder: (context) =>
                      const Icon(Icons.message, color: Colors.white),
                ),
                color: const Color(0xFF25D366),
                title: 'WhatsApp',
                subtitle: 'Enviar mensaje directo',
                onTap: () {
                  Navigator.pop(context);
                  _launchWhatsApp(phone, context);
                },
              ),
              const SizedBox(height: 16),

              _ContactOptionTile(
                icon: const Icon(
                  Icons.phone_in_talk_rounded,
                  color: AppColors.textDark,
                  size: 24,
                ),
                color: AppColors.primaryGold,
                title: 'Llamar',
                subtitle: phone, // Muestra el número
                onTap: () {
                  Navigator.pop(context);
                  launchUrl(Uri.parse('tel:$phone'));
                },
              ),
              const SizedBox(height: 16),

              _ContactOptionTile(
                icon: const Icon(
                  Icons.copy_all_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                color: Colors.grey[800]!,
                title: 'Copiar',
                subtitle: 'Copiar número al portapapeles',
                onTap: () async {
                  Navigator.pop(context);
                  await Clipboard.setData(ClipboardData(text: phone));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Número copiado al portapapeles'),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchWhatsApp(String phone, BuildContext context) async {
    // 1. Limpieza básica: dejar solo dígitos
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    // 2. Lógica de país (Asumiendo Venezuela +58 como default si no trae código)
    // Si empieza por '0' (ej: 0414...), quitamos el 0 inicial
    if (cleanPhone.startsWith('0')) {
      cleanPhone = cleanPhone.substring(1);
    }

    // Si la longitud es de 10 dígitos (ej: 4141234567), probablemente le falta el 58
    if (cleanPhone.length == 10) {
      cleanPhone = '58$cleanPhone';
    }

    final uri = Uri.parse('https://wa.me/$cleanPhone');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo abrir WhatsApp')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSocialMedia =
        instagramUrl != null || tiktokUrl != null || phoneNumber != null;

    if (!hasSocialMedia) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (instagramUrl != null) ...[
          _SocialMediaButton(
            iconPath: 'assets/icons/instagram.svg',
            label: 'Instagram',
            url: instagramUrl!,
            color: const Color(0xFFE4405F),
            iconSize: iconSize,
            showLabel: showLabels,
            onTap: () => _launchUrl(instagramUrl!, true, context),
          ),
          SizedBox(width: spacing),
        ],

        if (tiktokUrl != null) ...[
          _SocialMediaButton(
            iconPath: 'assets/icons/tiktok.svg',
            label: 'TikTok',
            url: tiktokUrl!,
            iconSize: iconSize,
            showLabel: showLabels,
            onTap: () => _launchUrl(tiktokUrl!, false, context),
          ),
          SizedBox(width: spacing),
        ],

        if (phoneNumber != null)
          _SocialMediaButton(
            iconPath: 'assets/icons/whatsapp.svg',
            label: 'WhatsApp',
            url: phoneNumber!,
            iconSize: iconSize,
            // color: const Color(0xFF25D366), // REMOVED: To avoid tinting the whole SVG if it's a solid block
            useIconFallback: true,
            fallbackIcon: Icons.perm_phone_msg,
            showLabel: showLabels,
            onTap: () => _showPhoneOptions(context, phoneNumber!),
          ),
      ],
    );
  }
}

/// Widget interno para las opciones del BottomSheet (Diseño mejorado)
class _ContactOptionTile extends StatelessWidget {
  final Widget icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactOptionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.backgroundCardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: icon,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.textSecondary.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
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
  final bool useIconFallback;
  final IconData? fallbackIcon;
  final bool showLabel;

  const _SocialMediaButton({
    required this.iconPath,
    required this.label,
    required this.url,
    required this.iconSize,
    required this.onTap,
    this.color,
    this.useIconFallback = false,
    this.fallbackIcon,
    this.showLabel = true,
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
              color: color != null
                  ? color!.withOpacity(0.5)
                  : Colors.grey.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono SVG o Fallback
              SizedBox(
                width: iconSize,
                height: iconSize,
                child: useIconFallback && fallbackIcon != null
                    ? Icon(fallbackIcon, color: color, size: iconSize)
                    : SvgPicture.asset(
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
              if (showLabel) ...[
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
            ],
          ),
        ),
      ),
    );
  }
}
