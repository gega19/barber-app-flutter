import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/user_entity.dart';
import '../common/app_avatar.dart';
import 'avatar_edit_button_widget.dart';

/// Widget para el header del perfil con avatar y nombre
class ProfileHeaderWidget extends StatelessWidget {
  final UserEntity user;
  final bool isUploadingAvatar;
  final VoidCallback onAvatarTap;

  const ProfileHeaderWidget({
    super.key,
    required this.user,
    required this.isUploadingAvatar,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AppAvatar(
                  key: ValueKey(
                    'profile_avatar_${user.id}_${user.avatarSeed ?? ''}_${user.avatar ?? ''}',
                  ),
                  imageUrl: user.avatar,
                  name: user.name,
                  avatarSeed: user.avatarSeed,
                  size: 96,
                  borderColor: AppColors.primaryGold,
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 400.ms),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: AvatarEditButtonWidget(
                    isUploading: isUploadingAvatar,
                    onTap: onAvatarTap,
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 200.ms)
                      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 400.ms, delay: 200.ms),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: const TextStyle(
                color: AppColors.primaryGold,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: 100.ms)
                .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: 100.ms),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: 200.ms)
                .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: 200.ms),
          ],
        ),
      ),
    );
  }
}

