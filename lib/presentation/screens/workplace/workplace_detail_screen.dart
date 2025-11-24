import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/injection/injection.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/reviews/workplace_reviews_tab.dart';
import '../../../domain/entities/workplace_entity.dart';
import '../../../domain/entities/barber_entity.dart';
import '../../../data/datasources/remote/workplace_remote_datasource.dart';
import '../../../data/datasources/remote/workplace_media_remote_datasource.dart';
import '../../../data/datasources/remote/barber_remote_datasource.dart';
import '../../../data/models/workplace_media_model.dart';
import '../../widgets/workplace/workplace_detail_header_widget.dart';
import '../../widgets/workplace/workplace_header_skeleton.dart';
import '../../widgets/workplace/workplace_info_card_widget.dart';
import '../../widgets/workplace/workplace_description_card_widget.dart';
import '../../widgets/workplace/workplace_media_grid_widget.dart';
import '../../widgets/workplace/workplace_barbers_list_widget.dart';
import '../../widgets/workplace/workplace_info_tab_widget.dart';
import 'package:shimmer/shimmer.dart';

class WorkplaceDetailScreen extends StatefulWidget {
  final String workplaceId;

  const WorkplaceDetailScreen({super.key, required this.workplaceId});

  @override
  State<WorkplaceDetailScreen> createState() => _WorkplaceDetailScreenState();
}

class _WorkplaceDetailScreenState extends State<WorkplaceDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  WorkplaceEntity? _workplace;
  List<BarberEntity> _barbers = [];
  List<WorkplaceMediaModel> _workplaceMedia = [];
  bool _loading = true;
  bool _loadingMedia = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadWorkplaceDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkplaceDetails() async {
    setState(() {
      _loading = true;
    });

    try {
      // Load workplace by ID directly
      final workplaceModel = await sl<WorkplaceRemoteDataSource>()
          .getWorkplaceById(widget.workplaceId);
      _workplace = workplaceModel;

      // Load workplace media and barbers in parallel
      await Future.wait([
        _loadWorkplaceMedia(),
        _loadBarbers(),
      ]);
    } catch (e) {
      // TODO: Replace with proper error handling
      print('Error loading workplace: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _loadWorkplaceMedia() async {
    setState(() {
      _loadingMedia = true;
    });

    try {
      final media = await sl<WorkplaceMediaRemoteDataSource>()
          .getWorkplaceMedia(widget.workplaceId);
      if (mounted) {
        setState(() {
          _workplaceMedia = media;
          _loadingMedia = false;
        });
      }
    } catch (e) {
      // TODO: Replace with proper error handling
      print('Error loading workplace media: $e');
      if (mounted) {
        setState(() {
          _loadingMedia = false;
        });
      }
    }
  }

  Future<void> _loadBarbers() async {
    setState(() {
      _loading = true;
    });

    try {
      final barberDataSource = sl<BarberRemoteDataSource>();
      final barbers = await barberDataSource.getBarbersByWorkplaceId(widget.workplaceId);

      if (mounted) {
        setState(() {
          _barbers = barbers;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _barbers = [];
          _loading = false;
        });
      }
      // TODO: Replace with proper error handling
      print('Error loading barbers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _workplace == null) {
      return Scaffold(
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
              const WorkplaceHeaderSkeleton(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Info Card Skeleton
                      Shimmer.fromColors(
                        baseColor: AppColors.backgroundCardDark,
                        highlightColor: AppColors.primaryGold.withOpacity(0.1),
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundCardDark,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Tabs Skeleton
                      Shimmer.fromColors(
                        baseColor: AppColors.backgroundCardDark,
                        highlightColor: AppColors.primaryGold.withOpacity(0.1),
                        child: Container(
                          height: 400,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundCardDark,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final workplace = _workplace!;

    return Scaffold(
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
            // Header with Banner
            WorkplaceDetailHeaderWidget(workplace: workplace),
            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Cards
                    if (workplace.address != null)
                      WorkplaceInfoCardWidget(address: workplace.address!)
                          .animate()
                          .fadeIn(duration: 300.ms, delay: 0.ms)
                          .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: 0.ms),
                    // Description
                    if (workplace.description != null &&
                        workplace.description!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      WorkplaceDescriptionCardWidget(
                        description: workplace.description!,
                      )
                          .animate()
                          .fadeIn(duration: 300.ms, delay: 100.ms)
                          .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: 100.ms),
                    ],
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
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                              ),
                              child: TabBar(
                                controller: _tabController,
                                indicatorSize: TabBarIndicatorSize.tab,
                                indicator: BoxDecoration(
                                  color: AppColors.primaryGold,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                labelColor: AppColors.textDark,
                                unselectedLabelColor: AppColors.textSecondary,
                                labelStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                unselectedLabelStyle: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                ),
                                dividerColor: Colors.transparent,
                                tabs: const [
                                  Tab(
                                    icon: Icon(Icons.image, size: 20),
                                    text: 'Multimedia',
                                  ),
                                  Tab(
                                    icon: Icon(Icons.people, size: 20),
                                    text: 'Barberos',
                                  ),
                                  Tab(
                                    icon: Icon(Icons.info, size: 20),
                                    text: 'Info',
                                  ),
                                  Tab(
                                    icon: Icon(Icons.star, size: 20),
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
                                  // Multimedia Tab
                                  RepaintBoundary(
                                    child: WorkplaceMediaGridWidget(
                                      media: _workplaceMedia,
                                      loading: _loadingMedia,
                                    ),
                                  )
                                      .animate(key: ValueKey('multimedia_tab'))
                                      .fadeIn(duration: 300.ms)
                                      .slideX(begin: 0.1, end: 0, duration: 300.ms),
                                  // Barbers Tab
                                  RepaintBoundary(
                                    child: WorkplaceBarbersListWidget(
                                      barbers: _barbers,
                                      loading: _loading,
                                    ),
                                  )
                                      .animate(key: ValueKey('barbers_tab'))
                                      .fadeIn(duration: 300.ms)
                                      .slideX(begin: 0.1, end: 0, duration: 300.ms),
                                  // Info Tab
                                  RepaintBoundary(
                                    child: WorkplaceInfoTabWidget(
                                      workplace: workplace,
                                    ),
                                  )
                                      .animate(key: ValueKey('info_tab'))
                                      .fadeIn(duration: 300.ms)
                                      .slideX(begin: 0.1, end: 0, duration: 300.ms),
                                  // Reviews Tab
                                  RepaintBoundary(
                                    child: WorkplaceReviewsTab(
                                      workplace: workplace,
                                    ),
                                  )
                                      .animate(key: ValueKey('reviews_tab'))
                                      .fadeIn(duration: 300.ms)
                                      .slideX(begin: 0.1, end: 0, duration: 300.ms),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 300.ms, delay: 200.ms)
                        .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: 200.ms),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
