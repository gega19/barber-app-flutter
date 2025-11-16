import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../cubit/barber/barber_cubit.dart';
import '../../cubit/promotion/promotion_cubit.dart';
import '../../cubit/workplace/workplace_cubit.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/discover/trending_workplace_card.dart';
import '../../widgets/discover/trending_workplace_skeleton.dart';
import '../../widgets/discover/trending_barber_card.dart';
import '../../widgets/discover/trending_barber_skeleton.dart';
import '../../widgets/discover/promotion_card.dart';
import '../../widgets/discover/promotion_card_skeleton.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar todos los datos necesarios al iniciar
    context.read<PromotionCubit>().loadPromotions();
    context.read<WorkplaceCubit>().loadWorkplaces();
    context.read<BarberCubit>().loadBarbers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                context.read<PromotionCubit>().loadPromotions(),
                context.read<WorkplaceCubit>().loadWorkplaces(),
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
                BlocBuilder<WorkplaceCubit, WorkplaceState>(
                  buildWhen: (previous, current) => previous != current,
                  builder: (context, state) {
                    // Mostrar skeleton mientras carga
                    if (state is! WorkplaceLoaded) {
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => const TrendingWorkplaceSkeleton(),
                          childCount: 3,
                        ),
                      );
                    }

                    // Ocultar sección completa si no hay items
                    if (state.workplaces.isEmpty) {
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    }

                    final trending = state.workplaces.take(3).toList();
                    final hasMore = state.workplaces.length > 3;

                    return SliverMainAxisGroup(
                      slivers: [
                        // Título de la sección
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.store,
                                        color: AppColors.primaryGold,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          'Barberías en Tendencia',
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (hasMore)
                                  IconButton(
                                    onPressed: () {
                                      context.push('/workplaces');
                                    },
                                    icon: const Icon(
                                      Icons.arrow_forward,
                                      color: AppColors.primaryGold,
                                      size: 20,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    tooltip: 'Ver más barberías',
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 8)),
                        // Lista de barberías
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return TrendingWorkplaceCard(
                                    workplace: trending[index],
                                  )
                                  .animate()
                                  .fadeIn(
                                    duration: const Duration(milliseconds: 300),
                                    delay: Duration(milliseconds: index * 50),
                                  )
                                  .slideY(
                                    begin: 0.1,
                                    end: 0,
                                    duration: const Duration(milliseconds: 300),
                                    delay: Duration(milliseconds: index * 50),
                                  );
                            },
                            childCount: trending.length,
                            addAutomaticKeepAlives: false,
                            addRepaintBoundaries: true,
                            addSemanticIndexes: false,
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 16)),
                      ],
                    );
                  },
                ),
                // Trending Barbers Section
                BlocBuilder<BarberCubit, BarberState>(
                  buildWhen: (previous, current) => previous != current,
                  builder: (context, state) {
                    // Mostrar skeleton mientras carga
                    if (state is! BarberLoaded) {
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => const TrendingBarberSkeleton(),
                          childCount: 3,
                        ),
                      );
                    }

                    // Ocultar sección completa si no hay items
                    if (state.barbers.isEmpty) {
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    }

                    final trending = state.barbers.take(3).toList();
                    final hasMore = state.barbers.length > 3;

                    return SliverMainAxisGroup(
                      slivers: [
                        // Título de la sección
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.trending_up,
                                        color: AppColors.primaryGold,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          'Barberos en Tendencia',
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (hasMore)
                                  IconButton(
                                    onPressed: () {
                                      context.push('/barbers');
                                    },
                                    icon: const Icon(
                                      Icons.arrow_forward,
                                      color: AppColors.primaryGold,
                                      size: 20,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    tooltip: 'Ver más barberos',
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 16)),
                        // Lista de barberos
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return TrendingBarberCard(
                                    barber: trending[index],
                                    position: index + 1,
                                  )
                                  .animate()
                                  .fadeIn(
                                    duration: const Duration(milliseconds: 300),
                                    delay: Duration(milliseconds: index * 50),
                                  )
                                  .slideY(
                                    begin: 0.1,
                                    end: 0,
                                    duration: const Duration(milliseconds: 300),
                                    delay: Duration(milliseconds: index * 50),
                                  );
                            },
                            childCount: trending.length,
                            addAutomaticKeepAlives: false,
                            addRepaintBoundaries: true,
                            addSemanticIndexes: false,
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      ],
                    );
                  },
                ),
                // Promotions Section
                BlocBuilder<PromotionCubit, PromotionState>(
                  buildWhen: (previous, current) => previous != current,
                  builder: (context, state) {
                    // Mostrar skeleton mientras carga
                    if (state is PromotionLoading) {
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => const PromotionCardSkeleton(),
                          childCount: 3,
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
                      // Ocultar sección completa si no hay items
                      if (state.promotions.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: SizedBox.shrink(),
                        );
                      }

                      final trendingPromotions = state.promotions
                          .take(3)
                          .toList();
                      final hasMore = state.promotions.length > 3;

                      return SliverMainAxisGroup(
                        slivers: [
                          // Título de la sección
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.local_offer,
                                          color: AppColors.primaryGold,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            'Promociones Especiales',
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (hasMore)
                                    IconButton(
                                      onPressed: () {
                                        context.push('/promotions');
                                      },
                                      icon: const Icon(
                                        Icons.arrow_forward,
                                        color: AppColors.primaryGold,
                                        size: 20,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      tooltip: 'Ver más promociones',
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 16)),
                          // Lista de promociones
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    left: 16,
                                    right: 16,
                                    bottom:
                                        index < trendingPromotions.length - 1
                                        ? 12
                                        : 0,
                                  ),
                                  child:
                                      PromotionCard(
                                            promotion:
                                                trendingPromotions[index],
                                          )
                                          .animate()
                                          .fadeIn(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            delay: Duration(
                                              milliseconds: index * 50,
                                            ),
                                          )
                                          .slideY(
                                            begin: 0.1,
                                            end: 0,
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            delay: Duration(
                                              milliseconds: index * 50,
                                            ),
                                          ),
                                );
                              },
                              childCount: trendingPromotions.length,
                              addAutomaticKeepAlives: false,
                              addRepaintBoundaries: true,
                              addSemanticIndexes: false,
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 24)),
                        ],
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
}
