import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/workplace_media_model.dart';
import '../../widgets/media/media_viewer_screen.dart';
import 'workplace_media_item_widget.dart';
import 'workplace_media_item_skeleton.dart';

/// Widget para mostrar el grid de multimedia de la barbería
class WorkplaceMediaGridWidget extends StatelessWidget {
  final List<WorkplaceMediaModel> media;
  final bool loading;

  const WorkplaceMediaGridWidget({
    super.key,
    required this.media,
    this.loading = false,
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
          return const WorkplaceMediaItemSkeleton();
        },
      );
    }

    if (media.isEmpty) {
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
              'No hay multimedia disponible',
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
      itemCount: media.length,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      addSemanticIndexes: false,
      itemBuilder: (context, index) {
        final mediaItem = media[index];
        return WorkplaceMediaItemWidget(
          key: ValueKey('workplace_media_${mediaItem.id}'),
          media: mediaItem,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MediaViewerScreen.fromWorkplaceMedia(
                  mediaList: media,
                  initialIndex: index,
                ),
              ),
            );
          },
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: Duration(milliseconds: index * 50))
            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 300.ms, delay: Duration(milliseconds: index * 50));
      },
    );
  }
}

