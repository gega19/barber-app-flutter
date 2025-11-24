import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/injection/injection.dart';
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
import '../../widgets/common/social_media_links_widget.dart';
import '../../../data/datasources/remote/service_remote_datasource.dart';
import '../../../data/datasources/remote/barber_course_remote_datasource.dart';
import '../../../domain/entities/barber_course_entity.dart';
import '../../../data/datasources/remote/barber_media_remote_datasource.dart';
import '../../../data/datasources/remote/workplace_remote_datasource.dart';
import '../../../data/models/service_model.dart';
import '../../../data/models/barber_media_model.dart';
import '../../../data/models/workplace_model.dart';
import '../../../data/models/promotion_model.dart';
import '../../../data/datasources/remote/promotion_remote_datasource.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/analytics_service.dart';
import 'package:dio/dio.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBarberDetails();
    _loadCurrentUserBarberId();
    _loadPromotions();
    // Cargar reseñas al iniciar
    context.read<ReviewCubit>().loadReviewsByBarber(widget.barberId);
    // Track barber view
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

    final userEmail = authState.user.email;

    try {
      final dio = sl<Dio>();
      final response = await dio.get('${AppConstants.baseUrl}/api/barbers');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        final matchingBarbers = data
            .where((b) => b['email'] == userEmail)
            .toList();

        if (matchingBarbers.isNotEmpty && mounted) {
          setState(() {
            _currentUserBarberId = matchingBarbers.first['id'] as String;
          });
        }
      }
    } catch (e) {
      // Error loading barber ID, continue without hiding the button
    }
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

      // Load barber details - we'll make a direct call to get workplace info
      // Since BarberModel doesn't include workplace data, we'll fetch it separately
      WorkplaceModel? workplace;
      String? serviceType;

      try {
        // Make a direct API call to get barber with workplace
        // Since we can't access raw JSON from BarberModel, we'll make a direct HTTP call
        final dio = sl<Dio>();
        final response = await dio.get(
          '${AppConstants.baseUrl}/api/barbers/${widget.barberId}',
        );
        if (response.statusCode == 200) {
          final barberJson = response.data['data'] as Map<String, dynamic>;
          serviceType = barberJson['serviceType'] as String?;

          // Get social media URLs
          final instagramUrl = barberJson['instagramUrl'] as String?;
          final tiktokUrl = barberJson['tiktokUrl'] as String?;

          // Get workplace if workplaceId exists
          if (barberJson['workplaceId'] != null) {
            final workplaceId = barberJson['workplaceId'] as String;
            workplace = await sl<WorkplaceRemoteDataSource>().getWorkplaceById(
              workplaceId,
            );
          } else if (barberJson['workplaceRef'] != null) {
            // If workplace is included in the response
            final workplaceJson =
                barberJson['workplaceRef'] as Map<String, dynamic>;
            workplace = WorkplaceModel.fromJson(workplaceJson);
          }

          setState(() {
            _instagramUrl = instagramUrl;
            _tiktokUrl = tiktokUrl;
          });
        }
      } catch (e) {
        // Ignore errors, just continue without workplace
      }

      setState(() {
        _services = services;
        _portfolio = portfolio;
        _courses = courses;
        _workplace = workplace;
        _serviceType = serviceType;
        _loadingDetails = false;
      });
    } catch (e) {
      setState(() {
        _loadingDetails = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BarberCubit, BarberState>(
      buildWhen: (previous, current) {
        // Solo rebuild cuando cambia el tipo de estado o los barberos
        if (previous.runtimeType != current.runtimeType) return true;
        if (previous is BarberLoaded && current is BarberLoaded) {
          // Rebuild si el barbero específico cambió o si cambió la lista
          try {
            final prevBarber = previous.barbers.firstWhere(
              (b) => b.id == widget.barberId,
            );
            final currBarber = current.barbers.firstWhere(
              (b) => b.id == widget.barberId,
            );
            // Rebuild si cambió rating, reviews, o cualquier campo relevante
            return prevBarber.rating != currBarber.rating ||
                prevBarber.reviews != currBarber.reviews ||
                prevBarber.name != currBarber.name;
          } catch (e) {
            return true;
          }
        }
        return false;
      },
      builder: (context, state) {
        if (state is! BarberLoaded) {
          return Scaffold(
            body: const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGold),
            ),
          );
        }

        final barber = state.barbers.firstWhere(
          (b) => b.id == widget.barberId,
          orElse: () => throw Exception('Barbero no encontrado'),
        );

        // Verificar si el usuario actual está viendo su propio perfil
        final isOwnProfile =
            _currentUserBarberId != null &&
            _currentUserBarberId == widget.barberId;

        return Stack(
          children: [
            Scaffold(
              floatingActionButton: isOwnProfile
                  ? null
                  : FloatingActionButton.extended(
                      onPressed: () => context.push('/booking/${barber.id}'),
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
                    // App Bar
                    BarberDetailHeaderWidget(
                      barber: barber,
                      instagramUrl: _instagramUrl,
                      tiktokUrl: _tiktokUrl,
                    ),
                    // Content
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Location
                            BarberLocationCardWidget(location: barber.location)
                                .animate()
                                .fadeIn(duration: 300.ms, delay: 0.ms)
                                .slideY(
                                  begin: 0.1,
                                  end: 0,
                                  duration: 300.ms,
                                  delay: 0.ms,
                                ),
                            const SizedBox(height: 16),
                            // Experience
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
                            // Services
                            BarberServicesListWidget(
                              services: _services,
                              loading: _loadingDetails,
                            ),
                            // Service Type
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
                            // Workplace
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
                            // Promotions Section
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
                            // Recent Reviews Section
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
                            // Tabs
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
                                              // Portfolio Tab
                                              BarberPortfolioGridWidget(
                                                    portfolio: _portfolio,
                                                    loading: _loadingDetails,
                                                  )
                                                  .animate(
                                                    key: ValueKey(
                                                      'portfolio_tab',
                                                    ),
                                                  )
                                                  .fadeIn(duration: 300.ms)
                                                  .slideX(
                                                    begin: 0.1,
                                                    end: 0,
                                                    duration: 300.ms,
                                                  ),
                                              // Info Tab
                                              BarberInfoTabWidget(
                                                    barber: barber,
                                                  )
                                                  .animate(
                                                    key: ValueKey('info_tab'),
                                                  )
                                                  .fadeIn(duration: 300.ms)
                                                  .slideX(
                                                    begin: 0.1,
                                                    end: 0,
                                                    duration: 300.ms,
                                                  ),
                                              // Reviews Tab
                                              ReviewsTab(barber: barber)
                                                  .animate(
                                                    key: ValueKey(
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
                            // Courses Section (below tabs)
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
