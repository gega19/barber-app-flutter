import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/injection/injection.dart';
import '../../cubit/barber/barber_cubit.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_avatar.dart';
import '../../widgets/common/app_badge.dart';
import '../../widgets/reviews/reviews_tab.dart';
import '../../widgets/media/media_viewer_screen.dart';
import '../../cubit/review/review_cubit.dart';
import '../../../domain/entities/review_entity.dart';
import '../../../data/datasources/remote/service_remote_datasource.dart';
import '../../../data/datasources/remote/barber_media_remote_datasource.dart';
import '../../../data/datasources/remote/workplace_remote_datasource.dart';
import '../../../data/models/service_model.dart';
import '../../../data/models/barber_media_model.dart';
import '../../../data/models/workplace_model.dart';
import '../../../core/constants/app_constants.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class BarberDetailScreen extends StatefulWidget {
  final String barberId;

  const BarberDetailScreen({
    super.key,
    required this.barberId,
  });

  @override
  State<BarberDetailScreen> createState() => _BarberDetailScreenState();
}

class _BarberDetailScreenState extends State<BarberDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<ServiceModel> _services = [];
  List<BarberMediaModel> _portfolio = [];
  WorkplaceModel? _workplace;
  String? _serviceType;
  bool _loadingDetails = true;
  String? _currentUserBarberId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBarberDetails();
    _loadCurrentUserBarberId();
    // Cargar reseñas al iniciar
    context.read<ReviewCubit>().loadReviewsByBarber(widget.barberId);
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
        final matchingBarbers = data.where(
          (b) => b['email'] == userEmail,
        ).toList();
        
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
      final services = await sl<ServiceRemoteDataSource>().getBarberServices(widget.barberId);
      
      // Load portfolio/media
      final portfolio = await sl<BarberMediaRemoteDataSource>().getBarberMedia(widget.barberId);
      
      // Load barber details - we'll make a direct call to get workplace info
      // Since BarberModel doesn't include workplace data, we'll fetch it separately
      WorkplaceModel? workplace;
      String? serviceType;
      
             try {
         // Make a direct API call to get barber with workplace
         // Since we can't access raw JSON from BarberModel, we'll make a direct HTTP call
         final dio = sl<Dio>();
         final response = await dio.get('${AppConstants.baseUrl}/api/barbers/${widget.barberId}');
        if (response.statusCode == 200) {
          final barberJson = response.data['data'] as Map<String, dynamic>;
          serviceType = barberJson['serviceType'] as String?;
          
          // Get workplace if workplaceId exists
          if (barberJson['workplaceId'] != null) {
            final workplaceId = barberJson['workplaceId'] as String;
            workplace = await sl<WorkplaceRemoteDataSource>().getWorkplaceById(workplaceId);
          } else if (barberJson['workplaceRef'] != null) {
            // If workplace is included in the response
            final workplaceJson = barberJson['workplaceRef'] as Map<String, dynamic>;
            workplace = WorkplaceModel.fromJson(workplaceJson);
          }
        }
      } catch (e) {
        // Ignore errors, just continue without workplace
      }
      
      setState(() {
        _services = services;
        _portfolio = portfolio;
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
      builder: (context, state) {
        if (state is! BarberLoaded) {
          return Scaffold(
            body: const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGold,
              ),
            ),
          );
        }

        final barber = state.barbers.firstWhere(
          (b) => b.id == widget.barberId,
          orElse: () => throw Exception('Barbero no encontrado'),
        );

        // Verificar si el usuario actual está viendo su propio perfil
        final isOwnProfile = _currentUserBarberId != null &&
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
                      icon: const Icon(Icons.calendar_today, color: AppColors.textDark),
                    ),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 200,
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
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.backgroundCard,
                            AppColors.backgroundDark,
                          ],
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            children: [
                              AppAvatar(
                                imageUrl: barber.image,
                                name: barber.name,
                                avatarSeed: barber.avatarSeed,
                                size: 96,
                                borderColor: AppColors.primaryGold,
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
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        if (barber.rating >= 4.8)
                                          AppBadge(
                                            text: 'Top',
                                            type: BadgeType.primary,
                                            icon: Icons.workspace_premium,
                                          ),
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
                                        Text(
                                          ' (${barber.reviews} reseñas)',
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Location
                        AppCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: AppColors.primaryGold,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Ubicación',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      barber.location,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Experience
                        AppCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.work_outline,
                                color: AppColors.primaryGold,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Experiencia',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${barber.experience} años',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Services
                        if (_services.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'Servicios',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...List.generate(_services.length, (index) {
                            final service = _services[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundCardDark,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.borderGold),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          service.name,
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '\$${service.price.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: AppColors.primaryGold,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (service.description != null && service.description!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      service.description!,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                  if (service.includes != null && service.includes!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.check_circle_outline,
                                          color: AppColors.primaryGold,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Incluye: ${service.includes}',
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }),
                        ],
                        // Workplace & Service Type
                        if (_workplace != null || _serviceType != null) ...[
                          const SizedBox(height: 24),
                          AppCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_workplace != null) ...[
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.store,
                                        color: AppColors.primaryGold,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Barbería',
                                              style: TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _workplace!.name,
                                              style: const TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            if (_workplace!.address != null) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                _workplace!.address!,
                                                style: const TextStyle(
                                                  color: AppColors.textSecondary,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_serviceType != null) const SizedBox(height: 16),
                                ],
                                if (_serviceType != null)
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.build_circle_outlined,
                                        color: AppColors.primaryGold,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Tipo de Servicio',
                                              style: TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _serviceType == 'LOCAL_ONLY'
                                                  ? 'Solo en local'
                                                  : _serviceType == 'HOME_SERVICE'
                                                      ? 'Servicio a domicilio'
                                                      : _serviceType == 'BOTH'
                                                          ? 'Ambos'
                                                          : _serviceType!,
                                              style: const TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        // Recent Reviews Section
                        BlocBuilder<ReviewCubit, ReviewState>(
                          builder: (context, reviewState) {
                            // Mostrar reseñas si están cargadas o si se acaba de crear una
                            List<ReviewEntity> reviewsToShow = [];
                            if (reviewState is ReviewLoaded) {
                              reviewsToShow = reviewState.reviews;
                            } else if (reviewState is ReviewCreated) {
                              // Si se acaba de crear una reseña, esperar a que se recarguen
                              // Por ahora mostrar mensaje vacío
                            }
                            
                            if (reviewsToShow.isNotEmpty) {
                              final recentReviews = reviewsToShow.take(3).toList();
                              final dateFormat = DateFormat('d MMM yyyy', 'es_ES');
                              
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
                                      ),
                                      if (barber.reviews > 3)
                                        TextButton(
                                          onPressed: () {
                                            // Cambiar al tab de reseñas
                                            _tabController.index = 2;
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
                                  ...recentReviews.map((review) {
                                    return AppCard(
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
                                                          dateFormat.format(review.createdAt),
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
                                    );
                                  }).toList(),
                                  const SizedBox(height: 24),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        // Tabs
                        AppCard(
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
                                      text: 'Portfolio',
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
                                    // Portfolio Tab
                                    _buildPortfolioTab(),
                                    // Info Tab
                                    _buildInfoTab(barber),
                                    // Reviews Tab
                                    ReviewsTab(barber: barber),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildPortfolioTab() {
    if (_loadingDetails) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryGold,
        ),
      );
    }

    if (_portfolio.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay portfolio disponible',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: _portfolio.length,
      itemBuilder: (context, index) {
        final media = _portfolio[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MediaViewerScreen(
                  mediaList: _portfolio,
                  initialIndex: index,
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundCardDark,
                border: Border.all(color: AppColors.borderGold),
                borderRadius: BorderRadius.circular(12),
              ),
              child: media.type == 'IMAGE' || media.type == 'GIF'
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: media.url.startsWith('http')
                              ? media.url
                              : '${AppConstants.baseUrl}${media.url}',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryGold,
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.error,
                            color: AppColors.error,
                          ),
                        ),
                        if (media.caption != null && media.caption!.isNotEmpty)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.7),
                                  ],
                                ),
                              ),
                              child: Text(
                                media.caption!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                      ],
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        if (media.thumbnail != null)
                          CachedNetworkImage(
                            imageUrl: media.thumbnail!.startsWith('http')
                                ? media.thumbnail!
                                : '${AppConstants.baseUrl}${media.thumbnail}',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.backgroundCardDark,
                            ),
                          )
                        else
                          Container(
                            color: AppColors.backgroundCardDark,
                          ),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_circle_filled,
                              color: AppColors.primaryGold,
                              size: 48,
                            ),
                          ),
                        ),
                        if (media.caption != null && media.caption!.isNotEmpty)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.7),
                                  ],
                                ),
                              ),
                              child: Text(
                                media.caption!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoTab(barber) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          const Text(
            'Información General',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            icon: Icons.location_on,
            label: 'Ubicación',
            value: barber.location,
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            icon: Icons.work_outline,
            label: 'Experiencia',
            value: '${barber.experience} años',
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            icon: Icons.category,
            label: 'Especialidad',
            value: barber.specialty,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColors.primaryGold,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

