import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/barber_entity.dart';
import '../common/app_card.dart';
import '../common/app_avatar.dart';
import '../common/app_badge.dart';

/// Widget reutilizable para mostrar un barbero en tendencia
class TrendingBarberCard extends StatelessWidget {
  final BarberEntity barber;
  final int position;

  const TrendingBarberCard({
    super.key,
    required this.barber,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: AppCard(
          onTap: () {
            context.push('/barber/${barber.id}');
          },
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AppAvatar(
                    imageUrl: barber.image,
                    name: barber.name,
                    avatarSeed: barber.avatarSeed,
                    size: 56,
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryGold,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$position',
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      barber.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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
                    AppBadge(
                      text: '+${(barber.rating * 10).toInt()}% esta semana',
                      type: BadgeType.success,
                      icon: Icons.trending_up,
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  const Icon(
                    Icons.star,
                    color: AppColors.primaryGold,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    barber.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: AppColors.primaryGold,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
