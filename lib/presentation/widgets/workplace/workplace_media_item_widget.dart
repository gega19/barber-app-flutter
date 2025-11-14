import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/workplace_media_model.dart';

/// Widget para mostrar un item individual de multimedia
class WorkplaceMediaItemWidget extends StatelessWidget {
  final WorkplaceMediaModel media;
  final VoidCallback onTap;

  const WorkplaceMediaItemWidget({
    super.key,
    required this.media,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundCardDark,
              border: Border.all(color: AppColors.borderGold),
              borderRadius: BorderRadius.circular(12),
            ),
            child: media.type == 'video'
                ? _buildVideoContent()
                : _buildImageContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: media.thumbnail != null
              ? (media.thumbnail!.startsWith('http')
                    ? media.thumbnail!
                    : '${AppConstants.baseUrl}${media.thumbnail}')
              : 'https://via.placeholder.com/300',
          fit: BoxFit.cover,
          alignment: Alignment.center,
          maxWidthDiskCache: 800,
          maxHeightDiskCache: 800,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGold),
          ),
          errorWidget: (context, url, error) => Container(
            color: AppColors.backgroundCardDark,
            child: const Icon(
              Icons.play_circle_outline,
              color: AppColors.primaryGold,
              size: 48,
            ),
          ),
        ),
        const Center(
          child: Icon(Icons.play_circle_filled, color: Colors.white, size: 48),
        ),
        if (media.caption != null && media.caption!.isNotEmpty)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
              child: Text(
                media.caption!,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageContent() {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: AppConstants.buildImageUrl(media.url),
          fit: BoxFit.cover,
          alignment: Alignment.center,
          maxWidthDiskCache: 800,
          maxHeightDiskCache: 800,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGold),
          ),
          errorWidget: (context, url, error) =>
              const Icon(Icons.error, color: AppColors.error),
        ),
        if (media.caption != null && media.caption!.isNotEmpty)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
              child: Text(
                media.caption!,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
      ],
    );
  }
}
