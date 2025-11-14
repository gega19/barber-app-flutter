import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/barber_utils.dart';
import '../../../domain/entities/barber_entity.dart';
import '../../../domain/entities/review_entity.dart';
import '../../cubit/review/review_cubit.dart';
import '../common/app_card.dart';
import '../common/app_avatar.dart';

/// Widget para mostrar las reseñas recientes del barbero
class BarberRecentReviewsWidget extends StatelessWidget {
  final BarberEntity barber;
  final TabController tabController;

  const BarberRecentReviewsWidget({
    super.key,
    required this.barber,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReviewCubit, ReviewState>(
      buildWhen: (previous, current) {
        // Solo rebuild cuando cambia el estado de reseñas
        if (previous.runtimeType != current.runtimeType) return true;
        if (previous is ReviewLoaded && current is ReviewLoaded) {
          return previous.reviews.length != current.reviews.length;
        }
        return false;
      },
      builder: (context, reviewState) {
        List<ReviewEntity> reviewsToShow = [];
        if (reviewState is ReviewLoaded) {
          reviewsToShow = reviewState.reviews;
        } else if (reviewState is ReviewCreated) {
          // Si se acaba de crear una reseña, esperar a que se recarguen
          return const SizedBox.shrink();
        }

        if (reviewsToShow.isEmpty) {
          return const SizedBox.shrink();
        }

        final recentReviews = reviewsToShow.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                      'Reseñas Recientes',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideX(begin: -0.1, end: 0, duration: 300.ms),
                if (barber.reviews > 3)
                  TextButton(
                    onPressed: () {
                      // Cambiar al tab de reseñas
                      tabController.index = 2;
                    },
                    child: const Text(
                      'Ver todas',
                      style: TextStyle(
                        color: AppColors.primaryGold,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ...recentReviews.asMap().entries.map((entry) {
              final index = entry.key;
              final review = entry.value;
              return RepaintBoundary(
                    key: ValueKey('review_${review.id}'),
                    child: AppCard(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppAvatar(
                                imageUrl: review.user.avatar,
                                name: review.user.name,
                                avatarSeed: review.user.avatarSeed,
                                size: 40,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            review.user.name,
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          BarberUtils.formatDate(
                                            review.createdAt,
                                          ),
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: List.generate(5, (i) {
                                        return Icon(
                                          Icons.star,
                                          size: 16,
                                          color: i < review.rating
                                              ? AppColors.primaryGold
                                              : AppColors.textSecondary,
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (review.comment != null &&
                              review.comment!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              review.comment!,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                height: 1.5,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(
                    duration: 300.ms,
                    delay: Duration(milliseconds: index * 100),
                  )
                  .slideY(
                    begin: 0.1,
                    end: 0,
                    duration: 300.ms,
                    delay: Duration(milliseconds: index * 100),
                  );
            }).toList(),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}
