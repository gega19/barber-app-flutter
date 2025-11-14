import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Widget para el botón de edición de avatar
class AvatarEditButtonWidget extends StatelessWidget {
  final bool isUploading;
  final VoidCallback onTap;

  const AvatarEditButtonWidget({
    super.key,
    required this.isUploading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUploading ? null : onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.primaryGold,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.backgroundCard,
            width: 2,
          ),
        ),
        child: isUploading
            ? const Padding(
                padding: EdgeInsets.all(6),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.textDark),
                ),
              )
            : const Icon(
                Icons.camera_alt,
                size: 16,
                color: AppColors.textDark,
              ),
      ),
    );
  }
}

