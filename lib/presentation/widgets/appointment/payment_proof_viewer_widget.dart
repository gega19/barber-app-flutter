import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/appointment_utils.dart';

/// Widget para mostrar y ver el comprobante de pago
class PaymentProofViewerWidget extends StatelessWidget {
  final String imageUrl;

  const PaymentProofViewerWidget({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final fullImageUrl = AppointmentUtils.buildImageUrl(imageUrl);

    return RepaintBoundary(
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: GestureDetector(
            onTap: () => _showFullScreenImage(context, fullImageUrl),
            child: CachedNetworkImage(
              imageUrl: fullImageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200,
              memCacheWidth: 800,
              memCacheHeight: 400,
              maxWidthDiskCache: 1000,
              maxHeightDiskCache: 1000,
              placeholder: (context, url) => Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.backgroundCardDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGold,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.backgroundCardDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.error,
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Toca la imagen para ver en pantalla completa',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain,
              memCacheWidth: 1920,
              memCacheHeight: 1080,
              maxWidthDiskCache: 2048,
              maxHeightDiskCache: 2048,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryGold,
                ),
              ),
              errorWidget: (context, url, error) => const Icon(
                Icons.error,
                color: AppColors.error,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

