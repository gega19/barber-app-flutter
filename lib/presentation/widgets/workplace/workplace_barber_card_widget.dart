import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/barber_entity.dart';
import '../common/app_card.dart';
import '../common/app_avatar.dart';

/// Widget para mostrar una tarjeta de barbero en la lista
class WorkplaceBarberCardWidget extends StatelessWidget {
  final BarberEntity barber;

  const WorkplaceBarberCardWidget({
    super.key,
    required this.barber,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AppCard(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        onTap: () {
          context.push('/barber/${barber.id}');
        },
        child: Row(
          children: [
            AppAvatar(
              imageUrl: barber.image,
              name: barber.name,
              avatarSeed: barber.avatarSeed,
              size: 56,
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
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppColors.primaryGold,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        barber.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

