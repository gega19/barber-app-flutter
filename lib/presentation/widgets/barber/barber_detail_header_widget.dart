import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/barber_entity.dart';
import '../../../core/utils/barber_utils.dart';
import '../common/app_avatar.dart';
import '../common/app_badge.dart';
import '../common/social_media_links_widget.dart';
import '../common/favorite_button.dart';
// import 'package:share_plus/share_plus.dart'; // Compartir deshabilitado temporalmente

/// Widget para el header del detalle del barbero
class BarberDetailHeaderWidget extends StatelessWidget {
  final BarberEntity barber;
  final String? instagramUrl;
  final String? tiktokUrl;
  final bool isLastCompetitionWinner;
  final int top1Count;
  final int top2Count;
  final int top3Count;

  const BarberDetailHeaderWidget({
    super.key,
    required this.barber,
    this.instagramUrl,
    this.tiktokUrl,
    this.isLastCompetitionWinner = false,
    this.top1Count = 0,
    this.top2Count = 0,
    this.top3Count = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: tiktokUrl != null || instagramUrl != null ? 280 : 240,
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
      actions: const [],
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
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppAvatar(
                              imageUrl: barber.image,
                              name: barber.name,
                              avatarSeed: barber.avatarSeed,
                              size: 96,
                              borderColor: AppColors.primaryGold,
                            ),
                            if (top1Count > 0 ||
                                top2Count > 0 ||
                                top3Count > 0) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                alignment: WrapAlignment.center,
                                children: [
                                  if (top1Count > 0)
                                    AppBadge(
                                      text:
                                          'Top 1${top1Count > 1 ? ' ($top1Count)' : ''}',
                                      type: BadgeType.primary,
                                      icon: Icons.emoji_events,
                                    ),
                                  if (top2Count > 0)
                                    AppBadge(
                                      text:
                                          'Top 2${top2Count > 1 ? ' ($top2Count)' : ''}',
                                      type: BadgeType.outline,
                                      icon: Icons.workspace_premium,
                                    ),
                                  if (top3Count > 0)
                                    AppBadge(
                                      text:
                                          'Top 3${top3Count > 1 ? ' ($top3Count)' : ''}',
                                      type: BadgeType.outline,
                                      icon: Icons.military_tech,
                                    ),
                                ],
                              ),
                            ],
                          ],
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
                                  Flexible(
                                    child: Text(
                                      ' (${barber.reviews} reseñas)',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  FavoriteButton(
                                    barberId: barber.id,
                                    color: AppColors.primaryGold,
                                    size: 24,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Social Media Links and Share Button below avatar and name
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (instagramUrl != null || tiktokUrl != null) ...[
                          SocialMediaLinksWidget(
                            instagramUrl: instagramUrl,
                            tiktokUrl: tiktokUrl,
                            iconSize: 18.0,
                            spacing: 8.0,
                          ),
                          const SizedBox(width: 16),
                        ],
                        // Opción Compartir deshabilitada temporalmente (deep link / web pendiente)
                        // Material(
                        //   color: Colors.transparent,
                        //   child: InkWell(
                        //     onTap: () {
                        //       final shareUrl =
                        //           barber.slug != null && barber.slug!.isNotEmpty
                        //               ? 'https://bartop.app/barber/${barber.slug}'
                        //               : 'https://bartop.app/barber/${barber.id}';
                        //       Share.share(
                        //         'Mira el perfil de ${barber.name} en Bartop! $shareUrl',
                        //         subject: 'Perfil de ${barber.name}',
                        //       );
                        //     },
                        //     borderRadius: BorderRadius.circular(20),
                        //     child: Container(
                        //       padding: const EdgeInsets.symmetric(
                        //         horizontal: 16,
                        //         vertical: 8,
                        //       ),
                        //       decoration: BoxDecoration(
                        //         border: Border.all(
                        //           color: AppColors.primaryGold,
                        //           width: 1.5,
                        //         ),
                        //         borderRadius: BorderRadius.circular(20),
                        //       ),
                        //       child: Row(
                        //         mainAxisSize: MainAxisSize.min,
                        //         children: const [
                        //           Icon(
                        //             Icons.share,
                        //             color: AppColors.primaryGold,
                        //             size: 18,
                        //           ),
                        //           SizedBox(width: 6),
                        //           Text(
                        //             'Compartir',
                        //             style: TextStyle(
                        //               color: AppColors.primaryGold,
                        //               fontSize: 14,
                        //               fontWeight: FontWeight.w600,
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
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
