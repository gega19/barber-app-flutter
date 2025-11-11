import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Avatar reutilizable con fallback
class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final String? avatarSeed;
  final double size;
  final Color? borderColor;

  const AppAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.avatarSeed,
    this.size = 40,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final border = borderColor ?? AppColors.primaryGold;
    final seed = avatarSeed ?? name.toLowerCase().replaceAll(' ', '');

    return Container(
      key: ValueKey('avatar_$seed'), // Force rebuild when seed changes
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 2),
        color: Colors.black,
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? CachedNetworkImage(
                key: ValueKey('avatar_image_$imageUrl'), // Force rebuild when image changes
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildDefaultAvatar(),
                errorWidget: (context, url, error) => _buildDefaultAvatar(),
              )
            : _buildDefaultAvatar(),
      ),
    );
  }

  String _getDefaultAvatarUrl() {
    final seed = avatarSeed ?? name.toLowerCase().replaceAll(' ', '');
    return 'https://api.dicebear.com/7.x/avataaars/png?seed=$seed&size=512'; // Removed timestamp to allow proper caching
  }

  Widget _buildDefaultAvatar() {
    final seed = avatarSeed ?? name.toLowerCase().replaceAll(' ', '');
    final avatarUrl = _getDefaultAvatarUrl();
    return CachedNetworkImage(
      key: ValueKey('default_avatar_$seed'), // Force rebuild when seed changes
      cacheKey: 'avatar_$seed', // Unique cache key based on seed
      imageUrl: avatarUrl,
      fit: BoxFit.cover,
      memCacheWidth: size.toInt(),
      memCacheHeight: size.toInt(),
      placeholder: (context, url) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryGold,
              AppColors.primaryGold.withValues(alpha: 0.6),
            ],
          ),
        ),
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryGold,
              AppColors.primaryGold.withValues(alpha: 0.6),
            ],
          ),
        ),
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}


