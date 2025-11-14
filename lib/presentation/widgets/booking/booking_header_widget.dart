import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/barber_entity.dart';
import '../common/app_avatar.dart';

/// Widget para el header del proceso de reserva
class BookingHeaderWidget extends StatelessWidget {
  final BarberEntity barber;

  const BookingHeaderWidget({
    super.key,
    required this.barber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderGold, width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.backgroundCardDark,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderGold),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.primaryGold,
                size: 20,
              ),
            ),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 12),
          AppAvatar(
            imageUrl: barber.image,
            name: barber.name,
            avatarSeed: barber.avatarSeed,
            size: 48,
            borderColor: AppColors.primaryGold,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  barber.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 14,
                      color: AppColors.primaryGold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      barber.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

