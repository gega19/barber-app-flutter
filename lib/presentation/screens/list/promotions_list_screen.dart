import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/promotion_entity.dart';
import '../../cubit/promotion/promotion_cubit.dart';
import '../../widgets/discover/promotion_card.dart';
import 'dart:async';

class PromotionsListScreen extends StatefulWidget {
  const PromotionsListScreen({super.key});

  @override
  State<PromotionsListScreen> createState() => _PromotionsListScreenState();
}

class _PromotionsListScreenState extends State<PromotionsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;
  String _searchQuery = '';
  String? _sortBy;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    context.read<PromotionCubit>().loadPromotions();
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

  List<PromotionEntity> _getFilteredAndSortedPromotions(
      List<PromotionEntity> promotions) {
    var filtered = List<PromotionEntity>.from(promotions);

    // Aplicar búsqueda
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((promotion) {
        return promotion.title.toLowerCase().contains(query) ||
            promotion.description.toLowerCase().contains(query) ||
            promotion.code.toLowerCase().contains(query) ||
            (promotion.barber?.name.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Aplicar ordenamiento
    if (_sortBy != null) {
      filtered.sort((a, b) {
        int comparison = 0;
        switch (_sortBy) {
          case 'title':
            comparison = a.title.compareTo(b.title);
            break;
          case 'validUntil':
            comparison = a.validUntil.compareTo(b.validUntil);
            break;
          case 'discount':
            final aDiscount = a.discount ?? a.discountAmount ?? 0;
            final bDiscount = b.discount ?? b.discountAmount ?? 0;
            comparison = aDiscount.compareTo(bDiscount);
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
            _buildSortOption('Título', 'title'),
            _buildSortOption('Fecha de vencimiento', 'validUntil'),
            _buildSortOption('Descuento', 'discount'),
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
          'Promociones',
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
      body: BlocBuilder<PromotionCubit, PromotionState>(
        builder: (context, state) {
          if (state is PromotionLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGold,
              ),
            );
          }

          if (state is PromotionError) {
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
                      context.read<PromotionCubit>().loadPromotions();
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

          if (state is PromotionLoaded) {
            final filteredPromotions =
                _getFilteredAndSortedPromotions(state.promotions);

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
                            hintText: 'Buscar por título, código o barbero...',
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
                          '${filteredPromotions.length} resultado${filteredPromotions.length != 1 ? 's' : ''}',
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
                              _sortBy == 'title'
                                  ? 'Título'
                                  : _sortBy == 'validUntil'
                                      ? 'Fecha'
                                      : 'Descuento',
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
                  child: filteredPromotions.isEmpty
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
                                'No se encontraron promociones',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            await context.read<PromotionCubit>().loadPromotions();
                          },
                          color: AppColors.primaryGold,
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredPromotions.length,
                            itemBuilder: (context, index) {
                              final promotion = filteredPromotions[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: PromotionCard(
                                  promotion: promotion,
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

