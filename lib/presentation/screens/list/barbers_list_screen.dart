import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/barber_entity.dart';
import '../../cubit/barber/barber_cubit.dart';
import '../../widgets/barber/barber_card_widget.dart';
import 'dart:async';

class BarbersListScreen extends StatefulWidget {
  const BarbersListScreen({super.key});

  @override
  State<BarbersListScreen> createState() => _BarbersListScreenState();
}

class _BarbersListScreenState extends State<BarbersListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;
  String _searchQuery = '';
  String? _sortBy;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    context.read<BarberCubit>().loadBarbers();
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

  List<BarberEntity> _getFilteredAndSortedBarbers(List<BarberEntity> barbers) {
    var filtered = List<BarberEntity>.from(barbers);

    // Aplicar búsqueda
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((barber) {
        return barber.name.toLowerCase().contains(query) ||
            barber.specialty.toLowerCase().contains(query) ||
            barber.location.toLowerCase().contains(query);
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
          'Barberos',
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
      body: BlocBuilder<BarberCubit, BarberState>(
        builder: (context, state) {
          if (state is BarberLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGold),
            );
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
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<BarberCubit>().loadBarbers();
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

          if (state is BarberLoaded) {
            final filteredBarbers = _getFilteredAndSortedBarbers(state.barbers);

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
                            hintText:
                                'Buscar por nombre, especialidad o ubicación...',
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
                          '${filteredBarbers.length} resultado${filteredBarbers.length != 1 ? 's' : ''}',
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
                            backgroundColor: AppColors.primaryGold.withOpacity(
                              0.2,
                            ),
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
                              _sortBy == 'rating' ? 'Calificación' : 'Nombre',
                            ),
                            onDeleted: () {
                              setState(() {
                                _sortBy = null;
                              });
                            },
                            backgroundColor: AppColors.primaryGold.withOpacity(
                              0.2,
                            ),
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
                  child: filteredBarbers.isEmpty
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
                                'No se encontraron barberos',
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
                          itemCount: filteredBarbers.length,
                          itemBuilder: (context, index) {
                            final barber = filteredBarbers[index];
                            return BarberCardWidget(
                                  barber: barber,
                                  onTap: () {
                                    context.push('/barber/${barber.id}');
                                  },
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
