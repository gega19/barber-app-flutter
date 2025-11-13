import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class MediaPlayer extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl;

  const MediaPlayer({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
  });

  @override
  State<MediaPlayer> createState() => _MediaPlayerState();
}

class _MediaPlayerState extends State<MediaPlayer> {
  ChewieController? _chewieController;
  VideoPlayerController? _videoPlayerController;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  String _getMediaUrl(String url) {
    return AppConstants.buildImageUrl(url);
  }

  Future<void> _initializePlayer() async {
    try {
      final videoUrl = _getMediaUrl(widget.videoUrl);
      
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      );

      await _videoPlayerController!.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout al inicializar el reproductor de video');
        },
      );

      if (!mounted) return;

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar el video',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primaryGold,
          handleColor: AppColors.primaryGold,
          backgroundColor: Colors.white.withValues(alpha: 0.3),
          bufferedColor: Colors.white.withValues(alpha: 0.5),
        ),
        placeholder: widget.thumbnailUrl != null
            ? CachedNetworkImage(
                imageUrl: _getMediaUrl(widget.thumbnailUrl!),
                fit: BoxFit.cover,
              )
            : Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGold,
                  ),
                ),
              ),
        autoInitialize: true,
      );

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar el video',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized || _chewieController == null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: widget.thumbnailUrl != null
              ? CachedNetworkImage(
                  imageUrl: _getMediaUrl(widget.thumbnailUrl!),
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGold,
                    ),
                  ),
                )
              : const CircularProgressIndicator(
                  color: AppColors.primaryGold,
                ),
        ),
      );
    }

    return Center(
      child: Chewie(
        controller: _chewieController!,
      ),
    );
  }
}
