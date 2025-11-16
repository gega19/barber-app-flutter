import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/workplace_entity.dart';
import '../../cubit/workplace/workplace_cubit.dart';
import '../../widgets/common/app_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';

class WorkplacesListScreen extends StatefulWidget {
  const WorkplacesListScreen({super.key});

  @override
  State<WorkplacesListScreen> createState() => _WorkplacesListScreenState();
}

class _WorkplacesListScreenState extends State<WorkplacesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;
  String _searchQuery = '';
  String? _sortBy;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    context.read<WorkplaceCubit>().loadWorkplaces();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  void _onScroll() {
    // Implementar paginación si es necesario
  }

  List<WorkplaceEntity> _getFilteredAndSortedWorkplaces(
      List<WorkplaceEntity> workplaces) {
    var filtered = List<WorkplaceEntity>.from(workplaces);

    // Aplicar búsqueda
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((workplace) {
        return workplace.name.toLowerCase().contains(query) ||
            (workplace.address?.toLowerCase().contains(query) ?? false) ||
            (workplace.city?.toLowerCase().contains(query) ?? false) ||
            (workplace.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Aplicar ordenamiento
    if (_sortBy != null) {
      filtered.sort((a, b) {
        int comparison = 0;
        switch (_sortBy) {
          case 'rating':
            comparison = a.rating.compareTo(b.rating);
            break;
          case 'name':
            comparison = a.name.compareTo(b.name);
            break;
          case 'reviews':
            comparison = a.reviews.compareTo(b.reviews);
            break;
          default:
            comparison = 0;
        }
        return _sortAscending ? comparison : -comparison;
      });
    }

    return filtered;
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ordenar por',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSortOption('Calificación', 'rating'),
            _buildSortOption('Nombre', 'name'),
            _buildSortOption('Reseñas', 'reviews'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _sortAscending = true;
                      });
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _sortAscending
                          ? AppColors.primaryGold
                          : AppColors.textSecondary,
                      side: BorderSide(
                        color: _sortAscending
                            ? AppColors.primaryGold
                            : AppColors.textSecondary,
                      ),
                    ),
                    child: const Text('Ascendente'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _sortAscending = false;
                      });
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: !_sortAscending
                          ? AppColors.primaryGold
                          : AppColors.textSecondary,
                      side: BorderSide(
                        color: !_sortAscending
                            ? AppColors.primaryGold
                            : AppColors.textSecondary,
                      ),
                    ),
                    child: const Text('Descendente'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, String value) {
    final isSelected = _sortBy == value;
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.primaryGold : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.primaryGold)
          : null,
      onTap: () {
        setState(() {
          _sortBy = value;
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Barberías',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.backgroundDark,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        elevation: 0,
      ),
      body: BlocBuilder<WorkplaceCubit, WorkplaceState>(
        builder: (context, state) {
          if (state is WorkplaceLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGold,
              ),
            );
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
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<WorkplaceCubit>().loadWorkplaces();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      foregroundColor: AppColors.textDark,
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is WorkplaceLoaded) {
            final filteredWorkplaces =
                _getFilteredAndSortedWorkplaces(state.workplaces);

            return Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Buscar por nombre, dirección o ciudad...',
                            hintStyle: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.textSecondary,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      color: AppColors.textSecondary,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: AppColors.backgroundCard,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _showSortOptions,
                        icon: const Icon(
                          Icons.sort,
                          color: AppColors.primaryGold,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.backgroundCard,
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ),
                // Results count
                if (_searchQuery.isNotEmpty || _sortBy != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text(
                          '${filteredWorkplaces.length} resultado${filteredWorkplaces.length != 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        if (_searchQuery.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(_searchQuery),
                            onDeleted: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                            backgroundColor: AppColors.primaryGold.withOpacity(0.2),
                            deleteIconColor: AppColors.primaryGold,
                            labelStyle: const TextStyle(
                              color: AppColors.primaryGold,
                            ),
                          ),
                        ],
                        if (_sortBy != null) ...[
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(
                              _sortBy == 'rating'
                                  ? 'Calificación'
                                  : _sortBy == 'name'
                                      ? 'Nombre'
                                      : 'Reseñas',
                            ),
                            onDeleted: () {
                              setState(() {
                                _sortBy = null;
                              });
                            },
                            backgroundColor: AppColors.primaryGold.withOpacity(0.2),
                            deleteIconColor: AppColors.primaryGold,
                            labelStyle: const TextStyle(
                              color: AppColors.primaryGold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                // List
                Expanded(
                  child: filteredWorkplaces.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: AppColors.textSecondary.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No se encontraron barberías',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredWorkplaces.length,
                          itemBuilder: (context, index) {
                            final workplace = filteredWorkplaces[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: AppCard(
                                onTap: () {
                                  context.push('/workplace/${workplace.id}');
                                },
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryGold
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: (workplace.image != null &&
                                              workplace.image!.isNotEmpty)
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: CachedNetworkImage(
                                                imageUrl: AppConstants.buildImageUrl(
                                                    workplace.image),
                                                fit: BoxFit.cover,
                                                width: 80,
                                                height: 80,
                                                memCacheWidth: 160,
                                                memCacheHeight: 160,
                                                maxWidthDiskCache: 200,
                                                maxHeightDiskCache: 200,
                                                fadeInDuration: const Duration(
                                                    milliseconds: 200),
                                                placeholder: (context, url) =>
                                                    Container(
                                                  color: AppColors.primaryGold
                                                      .withOpacity(0.2),
                                                  child: const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      color:
                                                          AppColors.primaryGold,
                                                      strokeWidth: 2,
                                                    ),
                                                  ),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Icon(
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.location_on,
                                                  size: 14,
                                                  color: AppColors.textSecondary,
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    workplace.city!,
                                                    style: const TextStyle(
                                                      color:
                                                          AppColors.textSecondary,
                                                      fontSize: 14,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
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
                                                workplace.rating
                                                    .toStringAsFixed(1),
                                                style: const TextStyle(
                                                  color: AppColors.textPrimary,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '(${workplace.reviews})',
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
                                    const Icon(
                                      Icons.chevron_right,
                                      color: AppColors.textSecondary,
                                    ),
                                  ],
                                ),
                              )
                                  .animate()
                                  .fadeIn(
                                    duration: 300.ms,
                                    delay: (index * 50).ms,
                                  )
                                  .slideY(
                                    begin: 0.1,
                                    end: 0,
                                    duration: 300.ms,
                                    delay: (index * 50).ms,
                                  ),
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

