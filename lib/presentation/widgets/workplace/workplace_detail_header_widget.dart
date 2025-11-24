import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/workplace_utils.dart';
import '../../../domain/entities/workplace_entity.dart';
import '../common/app_badge.dart';
import '../common/social_media_links_widget.dart';

/// Widget para el header del detalle de la barbería
class WorkplaceDetailHeaderWidget extends StatelessWidget {
  final WorkplaceEntity workplace;

  const WorkplaceDetailHeaderWidget({super.key, required this.workplace});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: workplace.instagramUrl != null || workplace.tiktokUrl != null ? 340 : 300,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: const SizedBox.shrink(),
      flexibleSpace: Stack(
        fit: StackFit.expand,
        children: [
          // Banner Image
          RepaintBoundary(
            child: CachedNetworkImage(
              imageUrl: WorkplaceUtils.getBannerUrl(workplace),
              fit: BoxFit.cover,
              alignment: Alignment.center,
              placeholder: (context, url) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.backgroundCard,
                      AppColors.backgroundDark,
                    ],
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGold,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.backgroundCard,
                      AppColors.backgroundDark,
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.store,
                    color: AppColors.primaryGold,
                    size: 64,
                  ),
                ),
              ),
            ),
          ),
          // Gradient Overlay at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 150,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),
          // Back Button
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => context.pop(),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Profile Info Overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        // Profile Image
                        RepaintBoundary(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primaryGold,
                                width: 3,
                              ),
                            ),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: AppConstants.buildImageUrl(
                                  WorkplaceUtils.getImageUrl(workplace),
                                ),
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                                memCacheWidth: 200,
                                memCacheHeight: 200,
                                maxWidthDiskCache: 400,
                                maxHeightDiskCache: 400,
                                placeholder: (context, url) => Container(
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGold.withValues(
                                      alpha: 0.2,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primaryGold,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGold.withValues(
                                      alpha: 0.2,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.store,
                                    color: AppColors.primaryGold,
                                    size: 48,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: RepaintBoundary(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        workplace.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black54,
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (WorkplaceUtils.isTopWorkplace(workplace))
                                      AppBadge(
                                        text: 'Top',
                                        type: BadgeType.primary,
                                        icon: Icons.workspace_premium,
                                      ),
                                  ],
                                ),
                                if (workplace.city != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    workplace.city!,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black54,
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: AppColors.primaryGold,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      workplace.rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black54,
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      ' (${workplace.reviews} reseñas)',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black54,
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Social Media Links below avatar and name
                    if (workplace.instagramUrl != null ||
                        workplace.tiktokUrl != null) ...[
                      const SizedBox(height: 16),
                      SocialMediaLinksWidget(
                        instagramUrl: workplace.instagramUrl,
                        tiktokUrl: workplace.tiktokUrl,
                        iconSize: 18.0,
                        spacing: 8.0,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
