import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Widget para mostrar un slot de hora individual
class TimeSlotWidget extends StatelessWidget {
  final String time;
  final bool isSelected;
  final VoidCallback onTap;

  const TimeSlotWidget({
    super.key,
    required this.time,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGold
              : AppColors.backgroundCardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGold
                : AppColors.borderGold,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            time,
            style: TextStyle(
              color: isSelected
                  ? AppColors.textDark
                  : AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      ),
    );
  }
}

