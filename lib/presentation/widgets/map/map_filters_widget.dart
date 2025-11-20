import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class MapFiltersWidget extends StatelessWidget {
  final String? selectedCity;
  final double? minRating;
  final double? maxDistanceKm;
  final double searchRadiusKm;
  final List<String> availableCities;
  final Function(String?) onCityChanged;
  final Function(double?) onMinRatingChanged;
  final Function(double?) onMaxDistanceChanged;
  final Function(double) onRadiusChanged;
  final VoidCallback onClearFilters;
  final bool hasActiveFilters;

  const MapFiltersWidget({
    super.key,
    this.selectedCity,
    this.minRating,
    this.maxDistanceKm,
    required this.searchRadiusKm,
    required this.availableCities,
    required this.onCityChanged,
    required this.onMinRatingChanged,
    required this.onMaxDistanceChanged,
    required this.onRadiusChanged,
    required this.onClearFilters,
    required this.hasActiveFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con título y botón de cerrar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtros',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (hasActiveFilters)
                TextButton(
                  onPressed: onClearFilters,
                  child: const Text(
                    'Limpiar',
                    style: TextStyle(
                      color: AppColors.primaryGold,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Radio de búsqueda
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Radio de búsqueda',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${searchRadiusKm.toStringAsFixed(1)} km',
                    style: const TextStyle(
                      color: AppColors.primaryGold,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Slider(
                value: searchRadiusKm,
                min: 1.0,
                max: 50.0,
                divisions: 49,
                activeColor: AppColors.primaryGold,
                inactiveColor: AppColors.textSecondary.withValues(alpha: 0.3),
                onChanged: (value) {
                  onRadiusChanged(value);
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildRadiusChip('1 km', 1.0),
                  _buildRadiusChip('5 km', 5.0),
                  _buildRadiusChip('10 km', 10.0),
                  _buildRadiusChip('25 km', 25.0),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Filtro por rating mínimo
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rating mínimo',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildRatingChip('Todos', null),
                  _buildRatingChip('3+ ⭐', 3.0),
                  _buildRatingChip('4+ ⭐', 4.0),
                  _buildRatingChip('4.5+ ⭐', 4.5),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Filtro por distancia máxima
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Distancia máxima',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildDistanceChip('Todas', null),
                  _buildDistanceChip('1 km', 1.0),
                  _buildDistanceChip('5 km', 5.0),
                  _buildDistanceChip('10 km', 10.0),
                  _buildDistanceChip('25 km', 25.0),
                ],
              ),
            ],
          ),
          
          if (availableCities.isNotEmpty) ...[
            const SizedBox(height: 20),
            // Filtro por ciudad
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ciudad',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildCityChip('Todas', null),
                    ...availableCities.take(10).map(
                      (city) => _buildCityChip(city, city),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRadiusChip(String label, double value) {
    final isSelected = (searchRadiusKm - value).abs() < 0.1;
    return GestureDetector(
      onTap: () => onRadiusChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGold
              : AppColors.backgroundCardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGold
                : AppColors.textSecondary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.textDark : AppColors.textPrimary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildRatingChip(String label, double? value) {
    final isSelected = minRating == value;
    return GestureDetector(
      onTap: () => onMinRatingChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGold
              : AppColors.backgroundCardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGold
                : AppColors.textSecondary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.textDark : AppColors.textPrimary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDistanceChip(String label, double? value) {
    final isSelected = maxDistanceKm == value;
    return GestureDetector(
      onTap: () => onMaxDistanceChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGold
              : AppColors.backgroundCardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGold
                : AppColors.textSecondary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.textDark : AppColors.textPrimary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCityChip(String label, String? value) {
    final isSelected = selectedCity == value;
    return GestureDetector(
      onTap: () => onCityChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGold
              : AppColors.backgroundCardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGold
                : AppColors.textSecondary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.textDark : AppColors.textPrimary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

