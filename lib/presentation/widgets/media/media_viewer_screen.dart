import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/barber_media_model.dart';
import '../../../data/models/workplace_media_model.dart';
import 'media_player.dart';

class MediaViewerScreen extends StatefulWidget {
  final List<BarberMediaModel> mediaList;
  final int initialIndex;

  const MediaViewerScreen({
    super.key,
    required this.mediaList,
    this.initialIndex = 0,
  });

  /// Factory constructor para crear desde WorkplaceMediaModel
  factory MediaViewerScreen.fromWorkplaceMedia({
    required List<WorkplaceMediaModel> mediaList,
    int initialIndex = 0,
  }) {
    // Convertir WorkplaceMediaModel a BarberMediaModel
    final barberMediaList = mediaList.map((workplaceMedia) {
      return BarberMediaModel(
        id: workplaceMedia.id,
        barberId: workplaceMedia.workplaceId, // Usar workplaceId como barberId temporalmente
        type: workplaceMedia.type.toUpperCase(), // Normalizar a mayúsculas
        url: workplaceMedia.url,
        thumbnail: workplaceMedia.thumbnail,
        caption: workplaceMedia.caption,
        createdAt: workplaceMedia.createdAt,
        updatedAt: workplaceMedia.updatedAt,
      );
    }).toList();

    return MediaViewerScreen(
      mediaList: barberMediaList,
      initialIndex: initialIndex,
    );
  }

  @override
  State<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends State<MediaViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNext() {
    if (_currentIndex < widget.mediaList.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  String _getMediaUrl(String url) {
    return AppConstants.buildImageUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${_currentIndex + 1} / ${widget.mediaList.length}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.mediaList.length,
            itemBuilder: (context, index) {
              final media = widget.mediaList[index];
              return _buildMediaItem(media);
            },
          ),
          if (widget.mediaList.length > 1)
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: _currentIndex > 0
                    ? _buildNavigationButton(
                        icon: Icons.chevron_left,
                        onTap: _goToPrevious,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          if (widget.mediaList.length > 1)
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: _currentIndex < widget.mediaList.length - 1
                    ? _buildNavigationButton(
                        icon: Icons.chevron_right,
                        onTap: _goToNext,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          if (widget.mediaList[_currentIndex].caption != null &&
              widget.mediaList[_currentIndex].caption!.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.9),
                    ],
                  ),
                ),
                child: Text(
                  widget.mediaList[_currentIndex].caption!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaItem(BarberMediaModel media) {
    // Normalizar el tipo a mayúsculas para comparación
    final normalizedType = media.type.toUpperCase();
    if (normalizedType == 'IMAGE' || normalizedType == 'GIF') {
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Center(
          child: CachedNetworkImage(
            imageUrl: _getMediaUrl(media.url),
            fit: BoxFit.contain,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGold),
            ),
            errorWidget: (context, url, error) => const Center(
              child: Icon(Icons.error, color: Colors.white, size: 64),
            ),
          ),
        ),
      );
    } else if (normalizedType == 'VIDEO') {
      return Center(
        child: MediaPlayer(
          videoUrl: _getMediaUrl(media.url),
          thumbnailUrl: media.thumbnail != null
              ? _getMediaUrl(media.thumbnail!)
              : null,
        ),
      );
    }
    return const Center(
      child: Icon(Icons.error, color: Colors.white, size: 64),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryGold, width: 2),
          ),
          child: Icon(icon, color: AppColors.primaryGold, size: 28),
        ),
      ),
    );
  }
}
