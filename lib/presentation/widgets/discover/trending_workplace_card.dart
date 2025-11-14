import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/workplace_entity.dart';
import '../common/app_card.dart';

/// Widget reutilizable para mostrar una barbería en tendencia
class TrendingWorkplaceCard extends StatelessWidget {
  final WorkplaceEntity workplace;

  const TrendingWorkplaceCard({super.key, required this.workplace});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: AppCard(
          onTap: () {
            context.push('/workplace/${workplace.id}');
          },
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withOpacity(0.2),
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                child: (workplace.image != null && workplace.image!.isNotEmpty)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: AppConstants.buildImageUrl(workplace.image),
                          fit: BoxFit.cover,
                          width: 56,
                          height: 56,
                          // Optimización de caché: reducir tamaño en memoria y disco
                          memCacheWidth: 112, // 2x para pantallas retina
                          memCacheHeight: 112,
                          maxWidthDiskCache: 200,
                          maxHeightDiskCache: 200,
                          fadeInDuration: const Duration(milliseconds: 200),
                          placeholder: (context, url) => Container(
                            color: AppColors.primaryGold.withOpacity(0.2),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryGold,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.store,
                            color: AppColors.primaryGold,
                            size: 28,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.store,
                        color: AppColors.primaryGold,
                        size: 28,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workplace.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (workplace.city != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        workplace.city!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                    if (workplace.address != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        workplace.address!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
