import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../cubit/barber/barber_cubit.dart';
import '../../cubit/promotion/promotion_cubit.dart';
import '../../cubit/workplace/workplace_cubit.dart';
import '../../../domain/entities/promotion_entity.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_badge.dart';
import '../../widgets/common/app_avatar.dart';
import '../../widgets/common/error_widget.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PromotionCubit>().loadPromotions();
    context.read<WorkplaceCubit>().loadWorkplaces(limit: 3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A1A),
              Color(0xFF0F0F0F),
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                context.read<PromotionCubit>().loadPromotions(),
                context.read<WorkplaceCubit>().loadWorkplaces(limit: 3),
                context.read<BarberCubit>().loadBarbers(),
              ]);
            },
            color: AppColors.primaryGold,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Descubrir',
                        style: TextStyle(
                          color: AppColors.primaryGold,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Explora tendencias y promociones',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Trending Workplaces Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.store,
                        color: AppColors.primaryGold,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Barberías en Tendencia',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              BlocBuilder<WorkplaceCubit, WorkplaceState>(
                builder: (context, state) {
                  if (state is WorkplaceLoaded && state.workplaces.isNotEmpty) {
                    final trending = state.workplaces.take(3).toList();
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final workplace = trending[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
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
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: (workplace.image != null && workplace.image!.isNotEmpty)
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: CachedNetworkImage(
                                              imageUrl: AppConstants.buildImageUrl(workplace.image),
                                              fit: BoxFit.cover,
                                              width: 56,
                                              height: 56,
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
                                  const Icon(
                                    Icons.chevron_right,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: trending.length,
                      ),
                    );
                  }
                  return const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              // Trending Barbers Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.trending_up,
                        color: AppColors.primaryGold,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Barberos en Tendencia',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              BlocBuilder<BarberCubit, BarberState>(
                builder: (context, state) {
                  if (state is BarberLoaded && state.barbers.isNotEmpty) {
                    final trending = state.barbers.take(3).toList();
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final barber = trending[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
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
                                              '${index + 1}',
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                          );
                        },
                        childCount: trending.length,
                      ),
                    );
                  }
                  return const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryGold,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              // Promotions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_offer,
                        color: AppColors.primaryGold,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Promociones Especiales',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              BlocBuilder<PromotionCubit, PromotionState>(
                builder: (context, state) {
                  if (state is PromotionLoading) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryGold,
                          ),
                        ),
                      ),
                    );
                  }

                  if (state is PromotionError) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: AppErrorWidget(
                          message: state.message,
                          onRetry: () {
                            context.read<PromotionCubit>().loadPromotions();
                          },
                        ),
                      ),
                    );
                  }

                  if (state is PromotionLoaded) {
                    if (state.promotions.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.local_offer_outlined,
                                  size: 64,
                                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No hay promociones disponibles',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final promotion = state.promotions[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: index < state.promotions.length - 1 ? 12 : 0,
                            ),
                            child: _buildPromotionCard(promotion),
                          );
                        },
                        childCount: state.promotions.length,
                      ),
                    );
                  }

                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPromotionCard(PromotionEntity promotion) {
    final dateFormat = DateFormat('d MMM yyyy', 'es_ES');
    final validUntil = dateFormat.format(promotion.validUntil);

    String discountText = '';
    if (promotion.discount != null) {
      discountText = '${promotion.discount!.toStringAsFixed(0)}% OFF';
    } else if (promotion.discountAmount != null) {
      discountText = '\$${promotion.discountAmount!.toStringAsFixed(0)} OFF';
    }

    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: promotion.barber != null
          ? () {
              context.push('/barber/${promotion.barber!.id}');
            }
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  promotion.title,
                  style: const TextStyle(
                    color: AppColors.primaryGold,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (discountText.isNotEmpty)
                AppBadge(
                  text: discountText,
                  type: BadgeType.success,
                )
              else
                AppBadge(
                  text: 'Activa',
                  type: BadgeType.primary,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            promotion.description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          if (promotion.barber != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.person,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Válido con ${promotion.barber!.name}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCardDark,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primaryGold,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Text(
                    promotion.code,
                    style: const TextStyle(
                      color: AppColors.primaryGold,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Válido hasta $validUntil',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
