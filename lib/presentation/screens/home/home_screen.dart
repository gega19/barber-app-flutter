import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../cubit/barber/barber_cubit.dart';
import '../../cubit/workplace/workplace_cubit.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/barber/barber_card_widget.dart';
import '../../../domain/entities/workplace_entity.dart';
import '../../../domain/entities/barber_entity.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;
  
  // Filtros
  String _sortBy = 'rating'; // 'rating', 'reviews'
  String _sortOrder = 'desc'; // 'asc', 'desc'
  String _searchQuery = ''; // Query de búsqueda

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<BarberCubit>().loadBestBarbers();
    context.read<WorkplaceCubit>().loadWorkplaces();
    
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    
    // Recargar datos si la búsqueda está vacía para mostrar todos los resultados
    if (query.isEmpty) {
      if (_tabController.index == 0) {
        context.read<BarberCubit>().loadBestBarbers();
      } else {
        context.read<WorkplaceCubit>().loadWorkplaces();
      }
    }
    // Si hay query, el filtrado se hace localmente en _applyBarberFilters/_applyWorkplaceFilters
  }

  List<WorkplaceEntity> _filterWorkplacesBySearch(
    List<WorkplaceEntity> workplaces,
    String query,
  ) {
    if (query.isEmpty) {
      return workplaces;
    }

    final lowerQuery = query.toLowerCase();
    return workplaces.where((workplace) {
      final nameMatch = workplace.name.toLowerCase().contains(lowerQuery);
      final cityMatch = workplace.city?.toLowerCase().contains(lowerQuery) ?? false;
      final addressMatch = workplace.address?.toLowerCase().contains(lowerQuery) ?? false;
      
      return nameMatch || cityMatch || addressMatch;
    }).toList();
  }

  List<BarberEntity> _filterBarbersBySearch(
    List<BarberEntity> barbers,
    String query,
  ) {
    if (query.isEmpty) {
      return barbers;
    }

    final lowerQuery = query.toLowerCase();
    return barbers.where((barber) {
      final nameMatch = barber.name.toLowerCase().contains(lowerQuery);
      final locationMatch = barber.location.toLowerCase().contains(lowerQuery);
      final specialtyMatch = barber.specialty.toLowerCase().contains(lowerQuery);
      
      return nameMatch || locationMatch || specialtyMatch;
    }).toList();
  }

  void _showFilters() {
    final isBarberTab = _tabController.index == 0;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _FiltersModal(
        sortBy: _sortBy,
        sortOrder: _sortOrder,
        isBarberTab: isBarberTab,
        onApply: (sortBy, sortOrder) {
          setState(() {
            _sortBy = sortBy;
            _sortOrder = sortOrder;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  List<BarberEntity> _applyBarberFilters(List<BarberEntity> barbers) {
    // Primero filtrar por búsqueda
    final filtered = _filterBarbersBySearch(barbers, _searchQuery);
    
    // Luego ordenar
    final sorted = List<BarberEntity>.from(filtered);
    
    sorted.sort((a, b) {
      int comparison = 0;
      
      switch (_sortBy) {
        case 'rating':
          comparison = a.rating.compareTo(b.rating);
          break;
        case 'reviews':
          comparison = a.reviews.compareTo(b.reviews);
          break;
        default:
          comparison = a.rating.compareTo(b.rating);
      }
      
      return _sortOrder == 'desc' ? -comparison : comparison;
    });
    
    return sorted;
  }

  List<WorkplaceEntity> _applyWorkplaceFilters(List<WorkplaceEntity> workplaces) {
    // Primero filtrar por búsqueda
    final filtered = _filterWorkplacesBySearch(workplaces, _searchQuery);
    
    // Luego ordenar
    final sorted = List<WorkplaceEntity>.from(filtered);
    
    sorted.sort((a, b) {
      int comparison = 0;
      
      switch (_sortBy) {
        case 'rating':
          comparison = a.rating.compareTo(b.rating);
          break;
        case 'reviews':
          comparison = a.reviews.compareTo(b.reviews);
          break;
        default:
          comparison = a.rating.compareTo(b.rating);
      }
      
      return _sortOrder == 'desc' ? -comparison : comparison;
    });
    
    return sorted;
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
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, authState) {
                        final userName = authState is AuthAuthenticated 
                            ? authState.user.name.split(' ').first // Solo el primer nombre
                            : 'Usuario';
                        
                        return Text(
                          'Hola, $userName',
                          style: const TextStyle(
                            color: AppColors.primaryGold,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '¿Listo para un nuevo look?',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Search
                    AppTextField(
                      hint: 'Buscar barberos, ubicación...',
                      controller: _searchController,
                      prefixIcon: Icons.search,
                      onChanged: (value) => _onSearchChanged(value ?? ''),
                    ),
                    const SizedBox(height: 16),
                    // Tabs
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCard,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderGold),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicatorColor: AppColors.primaryGold,
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: AppColors.textDark,
                        unselectedLabelColor: AppColors.textSecondary,
                        indicator: BoxDecoration(
                          color: AppColors.primaryGold,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        tabs: const [
                          Tab(text: 'Barberos'),
                          Tab(text: 'Barberías'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Filter Button
                    Row(
                      children: [
                        Expanded(
                          child: _tabController.index == 0
                              ? BlocBuilder<BarberCubit, BarberState>(
                                  builder: (context, state) {
                                    if (state is BarberLoaded) {
                                      final filtered = _applyBarberFilters(state.barbers);
                                      return Text(
                                        '${filtered.length} barberos encontrados',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                )
                              : BlocBuilder<WorkplaceCubit, WorkplaceState>(
                                  builder: (context, state) {
                                    if (state is WorkplaceLoaded) {
                                      final filtered = _applyWorkplaceFilters(state.workplaces);
                                      return Text(
                                        '${filtered.length} barberías encontradas',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.tune,
                            color: AppColors.primaryGold,
                          ),
                          onPressed: _showFilters,
                          tooltip: 'Filtros',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Barberos Tab
                    BlocBuilder<BarberCubit, BarberState>(
                      builder: (context, state) {
                        if (state is BarberLoading) {
                          return const LoadingListWidget();
                        }

                        if (state is BarberError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: AppColors.error,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  state.message,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<BarberCubit>().loadBestBarbers();
                                  },
                                  child: const Text('Reintentar'),
                                ),
                              ],
                            ),
                          );
                        }

                        if (state is BarberLoaded) {
                          final filteredBarbers = _applyBarberFilters(state.barbers);
                          
                          if (filteredBarbers.isEmpty) {
                            return RefreshIndicator(
                              onRefresh: () async {
                                context.read<BarberCubit>().loadBestBarbers();
                              },
                              color: AppColors.primaryGold,
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.5,
                                  child: const Center(
                                    child: Text(
                                      'No se encontraron barberos',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                          return RefreshIndicator(
                            onRefresh: () async {
                              context.read<BarberCubit>().loadBestBarbers();
                            },
                            color: AppColors.primaryGold,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredBarbers.length,
                              itemBuilder: (context, index) {
                                final barber = filteredBarbers[index];
                                return BarberCardWidget(
                                  barber: barber,
                                  onTap: () {
                                    context.push('/barber/${barber.id}');
                                  },
                                );
                              },
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                    // Barberías Tab
                    BlocBuilder<WorkplaceCubit, WorkplaceState>(
                      builder: (context, state) {
                        if (state is WorkplaceLoading) {
                          return const LoadingListWidget();
                        }

                        if (state is WorkplaceError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: AppColors.error,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  state.message,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<WorkplaceCubit>().loadWorkplaces();
                                  },
                                  child: const Text('Reintentar'),
                                ),
                              ],
                            ),
                          );
                        }

                        if (state is WorkplaceLoaded) {
                          final filteredWorkplaces = _applyWorkplaceFilters(state.workplaces);
                          
                          if (filteredWorkplaces.isEmpty) {
                            return RefreshIndicator(
                              onRefresh: () async {
                                context.read<WorkplaceCubit>().loadWorkplaces();
                              },
                              color: AppColors.primaryGold,
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.5,
                                  child: const Center(
                                    child: Text(
                                      'No se encontraron barberías',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                          return RefreshIndicator(
                            onRefresh: () async {
                              context.read<WorkplaceCubit>().loadWorkplaces();
                            },
                            color: AppColors.primaryGold,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredWorkplaces.length,
                              itemBuilder: (context, index) {
                                final workplace = filteredWorkplaces[index];
                                return AppCard(
                                  onTap: () {
                                    context.push('/workplace/${workplace.id}');
                                  },
                                  padding: const EdgeInsets.all(16),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 64,
                                        height: 64,
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryGold.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: (workplace.image != null && workplace.image!.isNotEmpty)
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: CachedNetworkImage(
                                                  imageUrl: workplace.image!.startsWith('http')
                                                      ? workplace.image!
                                                      : '${AppConstants.baseUrl}${workplace.image}',
                                                  fit: BoxFit.cover,
                                                  width: 64,
                                                  height: 64,
                                                  placeholder: (context, url) => Container(
                                                    color: AppColors.primaryGold.withValues(alpha: 0.2),
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
                                                    size: 32,
                                                  ),
                                                ),
                                              )
                                            : const Icon(
                                                Icons.store,
                                                color: AppColors.primaryGold,
                                                size: 32,
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
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  size: 16,
                                                  color: AppColors.primaryGold,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  workplace.rating.toStringAsFixed(1),
                                                  style: const TextStyle(
                                                    color: AppColors.textPrimary,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '(${workplace.reviews} reseñas)',
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
                                      const Icon(
                                        Icons.chevron_right,
                                        color: AppColors.textSecondary,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget Modal de Filtros
class _FiltersModal extends StatefulWidget {
  final String sortBy;
  final String sortOrder;
  final bool isBarberTab;
  final Function(String, String) onApply;

  const _FiltersModal({
    required this.sortBy,
    required this.sortOrder,
    required this.isBarberTab,
    required this.onApply,
  });

  @override
  State<_FiltersModal> createState() => _FiltersModalState();
}

class _FiltersModalState extends State<_FiltersModal> {
  late String _selectedSortBy;
  late String _selectedSortOrder;

  @override
  void initState() {
    super.initState();
    _selectedSortBy = widget.sortBy;
    _selectedSortOrder = widget.sortOrder;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtros',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Ordenar por',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip(
                label: 'Calificación',
                value: 'rating',
                isSelected: _selectedSortBy == 'rating',
                onTap: () => setState(() => _selectedSortBy = 'rating'),
              ),
              _buildFilterChip(
                label: 'Reseñas',
                value: 'reviews',
                isSelected: _selectedSortBy == 'reviews',
                onTap: () => setState(() => _selectedSortBy = 'reviews'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Orden',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFilterChip(
                  label: 'Mayor a menor',
                  value: 'desc',
                  isSelected: _selectedSortOrder == 'desc',
                  onTap: () => setState(() => _selectedSortOrder = 'desc'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip(
                  label: 'Menor a mayor',
                  value: 'asc',
                  isSelected: _selectedSortOrder == 'asc',
                  onTap: () => setState(() => _selectedSortOrder = 'asc'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_selectedSortBy, _selectedSortOrder);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: AppColors.textDark,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Aplicar Filtros',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGold
              : AppColors.backgroundCardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGold
                : AppColors.borderGold,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? AppColors.textDark
                : AppColors.textPrimary,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

