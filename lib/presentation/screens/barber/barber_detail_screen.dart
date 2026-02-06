import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/injection/injection.dart';
import '../../../core/services/analytics_service.dart';

import '../../../domain/entities/barber_entity.dart';
import '../../../domain/entities/barber_course_entity.dart';
import '../../../data/models/service_model.dart';
import '../../../data/models/barber_media_model.dart';
import '../../../data/models/workplace_model.dart';
import '../../../data/models/promotion_model.dart';

import '../../../data/datasources/remote/service_remote_datasource.dart';
import '../../../data/datasources/remote/barber_course_remote_datasource.dart';
import '../../../data/datasources/remote/barber_media_remote_datasource.dart';
import '../../../data/datasources/remote/workplace_remote_datasource.dart';
import '../../../data/datasources/remote/promotion_remote_datasource.dart';
import '../../cubit/barber/barber_cubit.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../../cubit/review/review_cubit.dart';

import '../../widgets/common/app_card.dart';
import '../../widgets/reviews/reviews_tab.dart';
import '../../widgets/barber/barber_detail_header_widget.dart';
import '../../widgets/barber/barber_location_card_widget.dart';
import '../../widgets/barber/barber_experience_card_widget.dart';
import '../../widgets/barber/barber_services_list_widget.dart';
import '../../widgets/barber/barber_workplace_card_widget.dart';
import '../../widgets/barber/barber_service_type_card_widget.dart';
import '../../widgets/barber/barber_promotion_card_widget.dart';
import '../../widgets/barber/barber_recent_reviews_widget.dart';
import '../../widgets/barber/barber_portfolio_grid_widget.dart';
import '../../widgets/barber/barber_info_tab_widget.dart';
import '../../widgets/barber/barber_courses_list_widget.dart';
import '../../../domain/usecases/competition/get_barber_top_positions_usecase.dart';

class BarberDetailScreen extends StatefulWidget {
  final String barberId;

  const BarberDetailScreen({super.key, required this.barberId});

  @override
  State<BarberDetailScreen> createState() => _BarberDetailScreenState();
}

class _BarberDetailScreenState extends State<BarberDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<ServiceModel> _services = [];
  List<BarberMediaModel> _portfolio = [];
  List<BarberCourseEntity> _courses = [];
  WorkplaceModel? _workplace;
  String? _serviceType;
  bool _loadingDetails = true;
  String? _currentUserBarberId;
  List<PromotionModel> _promotions = [];
  final PromotionRemoteDataSource _promotionDataSource =
      sl<PromotionRemoteDataSource>();
  String? _instagramUrl;
  String? _tiktokUrl;
  bool _isLastCompetitionWinner = false;
  int _top1Count = 0;
  int _top2Count = 0;
  int _top3Count = 0;

  BarberEntity?
  _backupBarber; // Store locally fetched barber if not in global state

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBarberDetails();
    _loadCurrentUserBarberId();
    _loadPromotions();
    _loadTopPositions();
    context.read<ReviewCubit>().loadReviewsByBarber(widget.barberId);

    // Initial check for barber in state
    final cubitState = context.read<BarberCubit>().state;
    if (cubitState is BarberLoaded) {
      try {
        cubitState.barbers.firstWhere((b) => b.id == widget.barberId);
      } catch (e) {
        // Not in list, handled by _loadBarberDetails
      }
    }

    sl<AnalyticsService>().trackEvent(
      eventName: 'barber_viewed',
      eventType: 'user_action',
      properties: {'barberId': widget.barberId},
    );
  }

  Future<void> _loadPromotions() async {
    try {
      final promotions = await _promotionDataSource.getPromotionsByBarber(
        widget.barberId,
      );
      if (mounted) {
        setState(() {
          _promotions = promotions;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _promotions = [];
        });
      }
    }
  }

  Future<void> _loadCurrentUserBarberId() async {
    if (!mounted) return;

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated || authState.user.role != 'BARBER') {
      return;
    }

    if (authState.user.barberId != null) {
      setState(() {
        _currentUserBarberId = authState.user.barberId;
      });
    }
  }

  Future<void> _loadTopPositions() async {
    try {
      final result = await sl<GetBarberTopPositionsUseCase>().call(
        widget.barberId,
      );
      if (!mounted) return;
      result.fold((_) {}, (data) {
        if (data != null) {
          setState(() {
            _top1Count = (data['top1'] as num?)?.toInt() ?? 0;
            _top2Count = (data['top2'] as num?)?.toInt() ?? 0;
            _top3Count = (data['top3'] as num?)?.toInt() ?? 0;
            _isLastCompetitionWinner = (data['isLastWinner'] as bool?) ?? false;
          });
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBarberDetails() async {
    setState(() {
      _loadingDetails = true;
    });

    try {
      // 1. Fetch Barber Entity backup via Cubit (Clean Architecture)
      final barberCubit = context.read<BarberCubit>();
      final fetchedBarber = await barberCubit.fetchBarberById(widget.barberId);

      if (mounted && fetchedBarber != null) {
        setState(() {
          _backupBarber = fetchedBarber;
        });
      }

      // Load services
      final services = await sl<ServiceRemoteDataSource>().getBarberServices(
        widget.barberId,
      );

      // Load portfolio/media
      final portfolio = await sl<BarberMediaRemoteDataSource>().getBarberMedia(
        widget.barberId,
      );

      // Load courses
      List<BarberCourseEntity> courses = [];
      try {
        final coursesData = await sl<BarberCourseRemoteDataSource>()
            .getBarberCourses(widget.barberId);
        courses = coursesData;
      } catch (e) {
        // Ignore errors loading courses
      }

      // Load details & workplace
      WorkplaceModel? workplace;
      String? serviceType;

      // Update additional fields from fetched barber if available
      if (fetchedBarber != null) {
        if (mounted) {
          setState(() {
            _instagramUrl = fetchedBarber.instagramUrl;
            _tiktokUrl = fetchedBarber.tiktokUrl;
          });
        }

        if (fetchedBarber.workplaceId != null) {
          try {
            workplace = await sl<WorkplaceRemoteDataSource>().getWorkplaceById(
              fetchedBarber.workplaceId!,
            );
          } catch (_) {}
        }
      }

      if (mounted) {
        setState(() {
          _services = services;
          _portfolio = portfolio;
          _courses = courses;
          _workplace = workplace;
          _serviceType =
              serviceType ??
              fetchedBarber?.specialty; // Use specialty as fallback
          _loadingDetails = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingDetails = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BarberCubit, BarberState>(
      buildWhen: (previous, current) {
        if (previous.runtimeType != current.runtimeType) return true;
        if (previous is BarberLoaded && current is BarberLoaded) {
          try {
            final prevBarber = previous.barbers.firstWhere(
              (b) => b.id == widget.barberId,
            );
            final currBarber = current.barbers.firstWhere(
              (b) => b.id == widget.barberId,
            );
            return prevBarber != currBarber;
          } catch (e) {
            return true;
          }
        }
        return false;
      },
      builder: (context, state) {
        BarberEntity? barber;

        // Try to find barber in state
        if (state is BarberLoaded) {
          try {
            barber = state.barbers.firstWhere((b) => b.id == widget.barberId);
          } catch (e) {
            // Barber not found in list
          }
        }

        // If not found in state, try local backup
        barber ??= _backupBarber;

        if (barber == null) {
          if (_loadingDetails) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primaryGold),
              ),
            );
          }

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppColors.textPrimary),
            ),
            backgroundColor: AppColors.backgroundCard,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No se encontró el barbero',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      foregroundColor: AppColors.textDark,
                    ),
                    onPressed: () => context.pop(),
                    child: const Text('Volver'),
                  ),
                ],
              ),
            ),
          );
        }

        final isOwnProfile =
            _currentUserBarberId != null &&
            _currentUserBarberId == widget.barberId;

        return Stack(
          children: [
            Scaffold(
              floatingActionButton: isOwnProfile
                  ? null
                  : FloatingActionButton.extended(
                      onPressed: () =>
                          context.push('/booking/${barber!.id}', extra: barber),
                      backgroundColor: AppColors.primaryGold,
                      label: const Text(
                        'Agendar Cita',
                        style: TextStyle(color: AppColors.textDark),
                      ),
                      icon: const Icon(
                        Icons.calendar_today,
                        color: AppColors.textDark,
                      ),
                    ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              body: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
                  ),
                ),
                child: CustomScrollView(
                  slivers: [
                    BarberDetailHeaderWidget(
                      barber: barber,
                      instagramUrl: _instagramUrl,
                      tiktokUrl: _tiktokUrl,
                      isLastCompetitionWinner: _isLastCompetitionWinner,
                      top1Count: _top1Count,
                      top2Count: _top2Count,
                      top3Count: _top3Count,
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BarberLocationCardWidget(
                                  location: barber.location,
                                  latitude: barber.latitude,
                                  longitude: barber.longitude,
                                )
                                .animate()
                                .fadeIn(duration: 300.ms, delay: 0.ms)
                                .slideY(
                                  begin: 0.1,
                                  end: 0,
                                  duration: 300.ms,
                                  delay: 0.ms,
                                ),
                            const SizedBox(height: 16),
                            BarberExperienceCardWidget(
                                  experience: barber.experience,
                                )
                                .animate()
                                .fadeIn(duration: 300.ms, delay: 100.ms)
                                .slideY(
                                  begin: 0.1,
                                  end: 0,
                                  duration: 300.ms,
                                  delay: 100.ms,
                                ),
                            const SizedBox(height: 24),
                            BarberServicesListWidget(
                              services: _services,
                              loading: _loadingDetails,
                            ),
                            if (_serviceType != null) ...[
                              const SizedBox(height: 24),
                              BarberServiceTypeCardWidget(
                                    serviceType: _serviceType,
                                  )
                                  .animate()
                                  .fadeIn(duration: 300.ms, delay: 200.ms)
                                  .slideY(
                                    begin: 0.1,
                                    end: 0,
                                    duration: 300.ms,
                                    delay: 200.ms,
                                  ),
                            ],
                            if (_workplace != null) ...[
                              const SizedBox(height: 24),
                              BarberWorkplaceCardWidget(workplace: _workplace)
                                  .animate()
                                  .fadeIn(duration: 300.ms, delay: 200.ms)
                                  .slideY(
                                    begin: 0.1,
                                    end: 0,
                                    duration: 300.ms,
                                    delay: 200.ms,
                                  ),
                            ],
                            if (_promotions.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              const Text(
                                'Promociones',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ..._promotions.asMap().entries.map((entry) {
                                final promotion = entry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: BarberPromotionCardWidget(
                                    key: ValueKey('promotion_${promotion.id}'),
                                    promotion: promotion,
                                  ),
                                );
                              }),
                            ],
                            const SizedBox(height: 24),
                            BarberRecentReviewsWidget(
                                  barber: barber,
                                  tabController: _tabController,
                                )
                                .animate()
                                .fadeIn(duration: 300.ms, delay: 300.ms)
                                .slideY(
                                  begin: 0.1,
                                  end: 0,
                                  duration: 300.ms,
                                  delay: 300.ms,
                                ),
                            const SizedBox(height: 24),
                            RepaintBoundary(
                                  child: AppCard(
                                    padding: EdgeInsets.zero,
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.backgroundCardDark,
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                  top: Radius.circular(12),
                                                ),
                                          ),
                                          child: TabBar(
                                            controller: _tabController,
                                            indicatorSize:
                                                TabBarIndicatorSize.tab,
                                            indicator: BoxDecoration(
                                              color: AppColors.primaryGold,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            labelColor: AppColors.textDark,
                                            unselectedLabelColor:
                                                AppColors.textSecondary,
                                            labelStyle: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            unselectedLabelStyle:
                                                const TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 14,
                                                ),
                                            dividerColor: Colors.transparent,
                                            tabs: const [
                                              Tab(
                                                icon: Icon(
                                                  Icons.image,
                                                  size: 20,
                                                ),
                                                text: 'Portfolio',
                                              ),
                                              Tab(
                                                icon: Icon(
                                                  Icons.info,
                                                  size: 20,
                                                ),
                                                text: 'Info',
                                              ),
                                              Tab(
                                                icon: Icon(
                                                  Icons.star,
                                                  size: 20,
                                                ),
                                                text: 'Reseñas',
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 400,
                                          child: TabBarView(
                                            controller: _tabController,
                                            children: [
                                              BarberPortfolioGridWidget(
                                                    portfolio: _portfolio,
                                                    loading: _loadingDetails,
                                                  )
                                                  .animate(
                                                    key: const ValueKey(
                                                      'portfolio_tab',
                                                    ),
                                                  )
                                                  .fadeIn(duration: 300.ms)
                                                  .slideX(
                                                    begin: 0.1,
                                                    end: 0,
                                                    duration: 300.ms,
                                                  ),
                                              BarberInfoTabWidget(
                                                    barber: barber,
                                                  )
                                                  .animate(
                                                    key: const ValueKey(
                                                      'info_tab',
                                                    ),
                                                  )
                                                  .fadeIn(duration: 300.ms)
                                                  .slideX(
                                                    begin: 0.1,
                                                    end: 0,
                                                    duration: 300.ms,
                                                  ),
                                              ReviewsTab(barber: barber)
                                                  .animate(
                                                    key: const ValueKey(
                                                      'reviews_tab',
                                                    ),
                                                  )
                                                  .fadeIn(duration: 300.ms)
                                                  .slideX(
                                                    begin: 0.1,
                                                    end: 0,
                                                    duration: 300.ms,
                                                  ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .animate()
                                .fadeIn(duration: 300.ms, delay: 400.ms)
                                .slideY(
                                  begin: 0.1,
                                  end: 0,
                                  duration: 300.ms,
                                  delay: 400.ms,
                                ),
                            if (_courses.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              BarberCoursesListWidget(
                                    courses: _courses,
                                    loading: _loadingDetails,
                                    maxItems: 2,
                                    barberId: widget.barberId,
                                    barberName: barber.name,
                                  )
                                  .animate()
                                  .fadeIn(duration: 300.ms, delay: 500.ms)
                                  .slideY(
                                    begin: 0.1,
                                    end: 0,
                                    duration: 300.ms,
                                    delay: 500.ms,
                                  ),
                            ],
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
