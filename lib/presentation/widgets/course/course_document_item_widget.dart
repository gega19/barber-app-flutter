import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';

class CourseDocumentItem {
  final String? id;
  final String url;
  final String? thumbnail;
  final String? caption;
  final String type;
  final File? localFile;
  final bool isUploading;

  CourseDocumentItem({
    this.id,
    required this.url,
    this.thumbnail,
    this.caption,
    required this.type,
    this.localFile,
    this.isUploading = false,
  });

  bool get isLocal => localFile != null;
  bool get isImage => true; // Solo imágenes por ahora
}

class CourseDocumentItemWidget extends StatelessWidget {
  final CourseDocumentItem document;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;
  final bool showRemoveButton;

  const CourseDocumentItemWidget({
    super.key,
    required this.document,
    this.onRemove,
    this.onTap,
    this.showRemoveButton = true,
  });

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
            child: document.localFile != null
                ? Image.file(
                    document.localFile!,
                    fit: BoxFit.contain,
                  )
                : CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGold,
                      ),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.error,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {
        if (document.isImage && document.url.isNotEmpty) {
          _showFullScreenImage(
            context,
            document.localFile != null ? document.localFile!.path : document.url,
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.backgroundCardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryGold.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            // Thumbnail or Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: document.isUploading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGold,
                        strokeWidth: 2,
                      ),
                    )
                  : document.isImage && document.url.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: document.localFile != null
                              ? Image.file(
                                  document.localFile!,
                                  fit: BoxFit.cover,
                                  width: 60,
                                  height: 60,
                                )
                              : CachedNetworkImage(
                                  imageUrl: document.url,
                                  fit: BoxFit.cover,
                                  width: 60,
                                  height: 60,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primaryGold,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => const Icon(
                                    Icons.broken_image,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                        )
                      : const Icon(
                          Icons.image,
                          color: AppColors.primaryGold,
                          size: 32,
                        ),
            ),
            const SizedBox(width: 12),
            // Document Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (document.caption != null && document.caption!.isNotEmpty)
                    Text(
                      document.caption!,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    const Text(
                      'Imagen',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    document.isLocal ? 'Pendiente de subir' : 'Subido',
                    style: TextStyle(
                      color: document.isLocal
                          ? AppColors.textSecondary
                          : AppColors.success,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Remove Button
            if (showRemoveButton && onRemove != null && !document.isUploading)
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: AppColors.error,
                  size: 20,
                ),
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }
}

