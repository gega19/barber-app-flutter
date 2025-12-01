import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Widget para el header del mapa con búsqueda y botones
class MapHeaderWidget extends StatelessWidget {
  final String searchQuery;
  final int workplacesCount;
  final bool hasActiveFilters;
  final TextEditingController searchController;
  final VoidCallback onFilterPressed;
  final VoidCallback onLocationPressed;
  final ValueChanged<String> onSearchChanged;

  const MapHeaderWidget({
    super.key,
    required this.searchQuery,
    required this.workplacesCount,
    required this.hasActiveFilters,
    required this.searchController,
    required this.onFilterPressed,
    required this.onLocationPressed,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundDark.withValues(alpha: 0.95),
              AppColors.backgroundDark.withValues(alpha: 0.0),
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mapa de Barberías',
                        style: TextStyle(
                          color: AppColors.primaryGold,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$workplacesCount barbería${workplacesCount != 1 ? 's' : ''} encontrada${workplacesCount != 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Botón de filtros
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: hasActiveFilters
                          ? AppColors.primaryGold
                          : AppColors.primaryGold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.filter_list,
                      color: hasActiveFilters
                          ? AppColors.primaryGold
                          : AppColors.textSecondary,
                    ),
                    onPressed: onFilterPressed,
                    tooltip: 'Filtros',
                  ),
                ),
                // Botón para centrar en ubicación
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryGold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.my_location,
                      color: AppColors.primaryGold,
                    ),
                    onPressed: onLocationPressed,
                    tooltip: 'Centrar en mi ubicación',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Barra de búsqueda
            TextField(
              controller: searchController,
              style: const TextStyle(
                color: AppColors.textPrimary,
              ),
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, dirección o ciudad...',
                hintStyle: const TextStyle(
                  color: AppColors.textSecondary,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          searchController.clear();
                          onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.backgroundCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.primaryGold.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.primaryGold.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryGold,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

