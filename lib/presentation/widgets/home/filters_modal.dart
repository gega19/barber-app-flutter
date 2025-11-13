import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/home_constants.dart';

/// Modal de filtros para el HomeScreen
class FiltersModal extends StatefulWidget {
  final String sortBy;
  final String sortOrder;
  final bool isBarberTab;
  final Function(String, String) onApply;

  const FiltersModal({
    super.key,
    required this.sortBy,
    required this.sortOrder,
    required this.isBarberTab,
    required this.onApply,
  });

  @override
  State<FiltersModal> createState() => _FiltersModalState();
}

class _FiltersModalState extends State<FiltersModal> {
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
                value: HomeConstants.sortByRating,
                isSelected: _selectedSortBy == HomeConstants.sortByRating,
                onTap: () => setState(
                  () => _selectedSortBy = HomeConstants.sortByRating,
                ),
              ),
              _buildFilterChip(
                label: 'Reseñas',
                value: HomeConstants.sortByReviews,
                isSelected: _selectedSortBy == HomeConstants.sortByReviews,
                onTap: () => setState(
                  () => _selectedSortBy = HomeConstants.sortByReviews,
                ),
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
                  value: HomeConstants.sortOrderDesc,
                  isSelected: _selectedSortOrder == HomeConstants.sortOrderDesc,
                  onTap: () => setState(
                    () => _selectedSortOrder = HomeConstants.sortOrderDesc,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip(
                  label: 'Menor a mayor',
                  value: HomeConstants.sortOrderAsc,
                  isSelected: _selectedSortOrder == HomeConstants.sortOrderAsc,
                  onTap: () => setState(
                    () => _selectedSortOrder = HomeConstants.sortOrderAsc,
                  ),
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
            color: isSelected ? AppColors.primaryGold : AppColors.borderGold,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.textDark : AppColors.textPrimary,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
