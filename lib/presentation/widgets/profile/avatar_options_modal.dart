import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Modal para mostrar opciones de cambio de avatar
class AvatarOptionsModal extends StatelessWidget {
  final bool hasAvatar;
  final VoidCallback onTakePhoto;
  final VoidCallback onChooseFromGallery;
  final VoidCallback onGenerateRandom;
  final VoidCallback? onRemove;

  const AvatarOptionsModal({
    super.key,
    required this.hasAvatar,
    required this.onTakePhoto,
    required this.onChooseFromGallery,
    required this.onGenerateRandom,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cambiar Avatar',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildOption(
            context,
            icon: Icons.camera_alt,
            title: 'Tomar Foto',
            subtitle: 'Usar la cámara para tomar una nueva foto',
            onTap: () {
              Navigator.pop(context);
              onTakePhoto();
            },
          ),
          const SizedBox(height: 12),
          _buildOption(
            context,
            icon: Icons.photo_library,
            title: 'Elegir de Galería',
            subtitle: 'Seleccionar una foto de tu galería',
            onTap: () {
              Navigator.pop(context);
              onChooseFromGallery();
            },
          ),
          const SizedBox(height: 12),
          _buildOption(
            context,
            icon: Icons.palette,
            title: 'Cambiar Avatar',
            subtitle: 'Generar un nuevo avatar aleatorio',
            onTap: () {
              Navigator.pop(context);
              onGenerateRandom();
            },
          ),
          if (hasAvatar && onRemove != null) ...[
            const SizedBox(height: 12),
            _buildOption(
              context,
              icon: Icons.delete,
              title: 'Eliminar Foto',
              subtitle: 'Volver al avatar generado',
              onTap: () {
                Navigator.pop(context);
                onRemove!();
              },
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          border: Border.all(color: AppColors.borderGold),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primaryGold,
                size: 24,
              ),
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
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

