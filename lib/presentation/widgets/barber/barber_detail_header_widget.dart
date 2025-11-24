import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/barber_entity.dart';
import '../../../core/utils/barber_utils.dart';
import '../common/app_avatar.dart';
import '../common/app_badge.dart';
import '../common/social_media_links_widget.dart';

/// Widget para el header del detalle del barbero
class BarberDetailHeaderWidget extends StatelessWidget {
  final BarberEntity barber;
  final String? instagramUrl;
  final String? tiktokUrl;

  const BarberDetailHeaderWidget({
    super.key,
    required this.barber,
    this.instagramUrl,
    this.tiktokUrl,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: tiktokUrl != null || instagramUrl != null ? 240 : 200,
      pinned: true,
      backgroundColor: AppColors.backgroundCard,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: AppColors.primaryGold,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back,
            color: AppColors.textDark,
            size: 20,
          ),
        ),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: RepaintBoundary(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.backgroundCard, AppColors.backgroundDark],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        AppAvatar(
                          imageUrl: barber.image,
                          name: barber.name,
                          avatarSeed: barber.avatarSeed,
                          size: 96,
                          borderColor: AppColors.primaryGold,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      barber.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (BarberUtils.isTopBarber(
                                    barber.rating,
                                  )) ...[
                                    const SizedBox(width: 8),
                                    AppBadge(
                                      text: 'Top',
                                      type: BadgeType.primary,
                                      icon: Icons.workspace_premium,
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                barber.specialty,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
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
                                    barber.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    ' (${barber.reviews} reseñas)',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Social Media Links below avatar and name
                    if (instagramUrl != null || tiktokUrl != null) ...[
                      const SizedBox(height: 16),
                      SocialMediaLinksWidget(
                        instagramUrl: instagramUrl,
                        tiktokUrl: tiktokUrl,
                        iconSize: 18.0,
                        spacing: 8.0,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
