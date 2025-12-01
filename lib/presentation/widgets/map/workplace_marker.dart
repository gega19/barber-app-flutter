import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/workplace_entity.dart';

class WorkplaceMarker extends StatelessWidget {
  final WorkplaceEntity workplace;
  final bool isSelected;
  final VoidCallback? onTap;

  const WorkplaceMarker({
    super.key,
    required this.workplace,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGold
              : AppColors.backgroundCard,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGold
                : AppColors.primaryGold.withValues(alpha: 0.5),
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.location_on,
          color: isSelected ? AppColors.textDark : AppColors.primaryGold,
          size: isSelected ? 32 : 28,
        ),
      ),
      ),
    );
  }
}

/// Widget para mostrar información de una barbería en el mapa
class WorkplaceInfoCard extends StatelessWidget {
  final WorkplaceEntity workplace;
  final double? distance;
  final VoidCallback? onViewDetails;
  final VoidCallback? onClose;

  const WorkplaceInfoCard({
    super.key,
    required this.workplace,
    this.distance,
    this.onViewDetails,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row principal: Avatar + Nombre y Ranking
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar en un cuadrado
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.backgroundCardDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryGold.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: (workplace.image != null && workplace.image!.isNotEmpty)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: AppConstants.buildImageUrl(workplace.image!),
                          fit: BoxFit.cover,
                          width: 80,
                          height: 80,
                          placeholder: (context, url) => Container(
                            color: AppColors.backgroundCardDark,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryGold,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.backgroundCardDark,
                            child: const Icon(
                              Icons.store,
                              color: AppColors.primaryGold,
                              size: 40,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.backgroundCardDark,
                        child: const Icon(
                          Icons.store,
                          color: AppColors.primaryGold,
                          size: 40,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              // Column con nombre y ranking
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Nombre
                    Text(
                      workplace.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Ranking - siempre visible
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.primaryGold.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: AppColors.primaryGold,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                workplace.rating > 0
                                    ? workplace.rating.toStringAsFixed(1)
                                    : '0.0',
                                style: const TextStyle(
                                  color: AppColors.primaryGold,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${workplace.reviews})',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (distance != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.info.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.info.withValues(alpha: 0.5),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.navigation,
                                  size: 14,
                                  color: AppColors.info,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${distance!.toStringAsFixed(1)} km',
                                  style: const TextStyle(
                                    color: AppColors.info,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Botón de cerrar
              if (onClose != null)
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.backgroundCardDark,
                    shape: const CircleBorder(),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Botón Ver Más
          if (onViewDetails != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onViewDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: AppColors.textDark,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_forward, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Ver Más',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
