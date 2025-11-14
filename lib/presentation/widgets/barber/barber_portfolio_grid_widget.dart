import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/barber_media_model.dart';
import '../../widgets/media/media_viewer_screen.dart';
import 'barber_portfolio_item_skeleton.dart';

/// Widget para mostrar el grid del portfolio del barbero
class BarberPortfolioGridWidget extends StatelessWidget {
  final List<BarberMediaModel> portfolio;
  final bool loading;

  const BarberPortfolioGridWidget({
    super.key,
    required this.portfolio,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return const BarberPortfolioItemSkeleton();
        },
      );
    }

    if (portfolio.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                  Icons.image_outlined,
                  size: 64,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                )
                .animate()
                .fadeIn(duration: 500.ms)
                .scale(delay: 200.ms, duration: 300.ms),
            const SizedBox(height: 16),
            Text(
                  'No hay portfolio disponible',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                )
                .animate()
                .fadeIn(duration: 500.ms, delay: 300.ms)
                .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: 300.ms),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: portfolio.length,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      addSemanticIndexes: false,
      itemBuilder: (context, index) {
        final media = portfolio[index];
        return RepaintBoundary(
              key: ValueKey('portfolio_${media.id}'),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MediaViewerScreen(
                        mediaList: portfolio,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCardDark,
                      border: Border.all(color: AppColors.borderGold),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _buildMediaContent(media),
                  ),
                ),
              ),
            )
            .animate()
            .fadeIn(
              duration: 300.ms,
              delay: Duration(milliseconds: index * 50),
            )
            .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1, 1),
              duration: 300.ms,
              delay: Duration(milliseconds: index * 50),
            );
      },
    );
  }

  Widget _buildMediaContent(BarberMediaModel media) {
    final normalizedType = media.type.toUpperCase();
    final isImage = normalizedType == 'IMAGE' || normalizedType == 'GIF';

    if (isImage) {
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
    } else {
      // Video
      return Stack(
        fit: StackFit.expand,
        children: [
          if (media.thumbnail != null)
            CachedNetworkImage(
              imageUrl: media.thumbnail!.startsWith('http')
                  ? media.thumbnail!
                  : '${AppConstants.baseUrl}${media.thumbnail}',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              maxWidthDiskCache: 800,
              maxHeightDiskCache: 800,
              placeholder: (context, url) =>
                  Container(color: AppColors.backgroundCardDark),
            )
          else
            Container(color: AppColors.backgroundCardDark),
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_circle_filled,
                color: AppColors.primaryGold,
                size: 48,
              ),
            ),
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
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      );
    }
  }
}
