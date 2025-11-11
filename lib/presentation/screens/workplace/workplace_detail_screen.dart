import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/injection/injection.dart';
import '../../cubit/barber/barber_cubit.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_avatar.dart';
import '../../widgets/common/app_badge.dart';
import '../../widgets/reviews/workplace_reviews_tab.dart';
import '../../../domain/entities/workplace_entity.dart';
import '../../../domain/entities/barber_entity.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/datasources/remote/workplace_remote_datasource.dart';
import '../../../data/datasources/remote/workplace_media_remote_datasource.dart';
import '../../../data/models/workplace_media_model.dart';
import '../../widgets/media/media_player.dart';

class WorkplaceDetailScreen extends StatefulWidget {
  final String workplaceId;

  const WorkplaceDetailScreen({
    super.key,
    required this.workplaceId,
  });

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
      final workplaceModel = await sl<WorkplaceRemoteDataSource>().getWorkplaceById(widget.workplaceId);
      _workplace = workplaceModel;

      // Load workplace media
      _loadWorkplaceMedia();

      // Load barbers
      final barberCubit = context.read<BarberCubit>();
      await barberCubit.loadBarbers();

      if (barberCubit.state is BarberLoaded) {
        final allBarbers = (barberCubit.state as BarberLoaded).barbers;
        // Filter barbers that belong to this workplace
        // Note: This would need workplaceId in BarberEntity, for now we'll show all
        _barbers = allBarbers;
      }
    } catch (e) {
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
      final media = await sl<WorkplaceMediaRemoteDataSource>().getWorkplaceMedia(widget.workplaceId);
      setState(() {
        _workplaceMedia = media;
        _loadingMedia = false;
      });
    } catch (e) {
      print('Error loading workplace media: $e');
      setState(() {
        _loadingMedia = false;
      });
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
              colors: [
                Color(0xFF1A1A1A),
                Color(0xFF0F0F0F),
              ],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryGold,
            ),
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
            colors: [
              Color(0xFF1A1A1A),
              Color(0xFF0F0F0F),
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // App Bar with Banner
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: const SizedBox.shrink(), // Remove default leading
              flexibleSpace: Stack(
                fit: StackFit.expand,
                children: [
                  // Banner Image
                  CachedNetworkImage(
                    imageUrl: (workplace.banner != null && workplace.banner!.isNotEmpty)
                        ? (workplace.banner!.startsWith('http')
                            ? workplace.banner!
                            : '${AppConstants.baseUrl}${workplace.banner}')
                        : 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=1200&h=600&fit=crop',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
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
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryGold,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
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
                      child: const Center(
                        child: Icon(
                          Icons.store,
                          color: AppColors.primaryGold,
                          size: 64,
                        ),
                      ),
                    ),
                  ),
                  // Gradient Overlay at bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 150,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Back Button - Facebook style (centered in top left corner)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => context.pop(),
                              child: const Center(
                                child: Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Profile Info Overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          children: [
                            // Profile Image
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primaryGold,
                                  width: 3,
                                ),
                              ),
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: (workplace.image != null && workplace.image!.isNotEmpty)
                                      ? (workplace.image!.startsWith('http')
                                          ? workplace.image!
                                          : '${AppConstants.baseUrl}${workplace.image}')
                                      : 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=200&h=200&fit=crop',
                                  width: 96,
                                  height: 96,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: 96,
                                    height: 96,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGold.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.primaryGold,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    width: 96,
                                    height: 96,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGold.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.store,
                                      color: AppColors.primaryGold,
                                      size: 48,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          workplace.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black54,
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (workplace.rating >= 4.8)
                                        AppBadge(
                                          text: 'Top',
                                          type: BadgeType.primary,
                                          icon: Icons.workspace_premium,
                                        ),
                                    ],
                                  ),
                                  if (workplace.city != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      workplace.city!,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black54,
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
                                        workplace.rating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black54,
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        ' (${workplace.reviews} reseñas)',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black54,
                                              blurRadius: 4,
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
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Cards
                    Row(
                      children: [
                        if (workplace.address != null)
                          Expanded(
                            child: AppCard(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: AppColors.primaryGold,
                                    size: 24,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Dirección',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    workplace.address!,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (workplace.description != null && workplace.description!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Descripción',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              workplace.description!,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
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
                                    _buildMultimediaTab(workplace),
                                    // Barbers Tab
                                    _buildBarbersTab(),
                                    // Info Tab
                                    _buildInfoTab(workplace),
                                    // Reviews Tab
                                    WorkplaceReviewsTab(workplace: workplace),
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
    );
  }

  Widget _buildMultimediaTab(WorkplaceEntity workplace) {
    if (_loadingMedia) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryGold,
        ),
      );
    }

    if (_workplaceMedia.isEmpty) {
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
              'No hay multimedia disponible',
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
      itemCount: _workplaceMedia.length,
      itemBuilder: (context, index) {
        final media = _workplaceMedia[index];
        return GestureDetector(
          onTap: () {
            // Convert WorkplaceMediaModel to BarberMediaModel for MediaViewerScreen
            // Since MediaViewerScreen expects BarberMediaModel, we'll create a simple viewer
            // or we can update MediaViewerScreen to accept a generic media type
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  backgroundColor: Colors.black,
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    iconTheme: const IconThemeData(color: Colors.white),
                  ),
                  body: Center(
                    child: media.type == 'video'
                        ? MediaPlayer(
                            videoUrl: media.url.startsWith('http')
                                ? media.url
                                : '${AppConstants.baseUrl}${media.url}',
                            thumbnailUrl: media.thumbnail,
                          )
                        : CachedNetworkImage(
                            imageUrl: media.url.startsWith('http')
                                ? media.url
                                : '${AppConstants.baseUrl}${media.url}',
                            fit: BoxFit.contain,
                          ),
                  ),
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
              child: media.type == 'video'
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: media.thumbnail != null
                              ? (media.thumbnail!.startsWith('http')
                                  ? media.thumbnail!
                                  : '${AppConstants.baseUrl}${media.thumbnail}')
                              : 'https://via.placeholder.com/300',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryGold,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.backgroundCardDark,
                            child: const Icon(
                              Icons.play_circle_outline,
                              color: AppColors.primaryGold,
                              size: 48,
                            ),
                          ),
                        ),
                        const Center(
                          child: Icon(
                            Icons.play_circle_filled,
                            color: Colors.white,
                            size: 48,
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
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBarbersTab() {
    if (_barbers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay barberos disponibles',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _barbers.length,
      itemBuilder: (context, index) {
        final barber = _barbers[index];
        return AppCard(
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
        );
      },
    );
  }

  Widget _buildInfoTab(WorkplaceEntity workplace) {
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
          if (workplace.address != null)
            _buildInfoItem(
              icon: Icons.location_on,
              label: 'Dirección',
              value: workplace.address!,
            ),
          if (workplace.city != null) ...[
            const SizedBox(height: 12),
            _buildInfoItem(
              icon: Icons.location_city,
              label: 'Ciudad',
              value: workplace.city!,
            ),
          ],
          const SizedBox(height: 12),
          _buildInfoItem(
            icon: Icons.star,
            label: 'Calificación',
            value: '${workplace.rating.toStringAsFixed(1)} (${workplace.reviews} reseñas)',
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

