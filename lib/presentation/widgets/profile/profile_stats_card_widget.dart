import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/profile_utils.dart';
import '../common/app_card.dart';
import 'profile_stat_item_widget.dart';

/// Widget para mostrar la tarjeta de estadísticas del perfil
class ProfileStatsCardWidget extends StatelessWidget {
  final Map<String, dynamic>? stats;
  final bool isBarber;
  final bool loading;

  const ProfileStatsCardWidget({
    super.key,
    required this.stats,
    required this.isBarber,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AppCard(
          padding: const EdgeInsets.all(16),
          child: loading
              ? _buildLoadingState()
              : isBarber
                  ? _buildBarberStats()
                  : _buildClientStats(),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(3, (index) {
        return Column(
          children: [
            Shimmer.fromColors(
              baseColor: AppColors.backgroundCardDark,
              highlightColor: AppColors.primaryGold.withOpacity(0.1),
              child: Container(
                width: 40,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.backgroundCardDark,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Shimmer.fromColors(
              baseColor: AppColors.backgroundCardDark,
              highlightColor: AppColors.primaryGold.withOpacity(0.1),
              child: Container(
                width: 50,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.backgroundCardDark,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildBarberStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ProfileStatItemWidget(
          key: ValueKey('stat_appointments_${stats?['totalAppointments']}'),
          value: (stats?['totalAppointments'] ?? 0).toString(),
          label: 'Citas',
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: 50.ms)
            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 300.ms, delay: 50.ms),
        Container(
          width: 1,
          height: 40,
          color: AppColors.borderGold,
        ),
        ProfileStatItemWidget(
          key: ValueKey('stat_rating_${stats?['rating']}'),
          value: ProfileUtils.formatStatValue(stats?['rating'] ?? 0.0),
          label: 'Puntuación',
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: 100.ms)
            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 300.ms, delay: 100.ms),
        Container(
          width: 1,
          height: 40,
          color: AppColors.borderGold,
        ),
        ProfileStatItemWidget(
          key: ValueKey('stat_clients_${stats?['uniqueClients']}'),
          value: (stats?['uniqueClients'] ?? 0).toString(),
          label: 'Clientes',
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: 150.ms)
            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 300.ms, delay: 150.ms),
      ],
    );
  }

  Widget _buildClientStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ProfileStatItemWidget(
          key: ValueKey('stat_appointments_${stats?['totalAppointments']}'),
          value: (stats?['totalAppointments'] ?? 0).toString(),
          label: 'Citas',
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: 50.ms)
            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 300.ms, delay: 50.ms),
        Container(
          width: 1,
          height: 40,
          color: AppColors.borderGold,
        ),
        ProfileStatItemWidget(
          key: ValueKey('stat_spent_${stats?['totalSpent']}'),
          value: ProfileUtils.formatCurrency(stats?['totalSpent'] ?? 0.0),
          label: 'Gastado',
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: 100.ms)
            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 300.ms, delay: 100.ms),
        Container(
          width: 1,
          height: 40,
          color: AppColors.borderGold,
        ),
        ProfileStatItemWidget(
          key: ValueKey('stat_barbers_${stats?['uniqueBarbers']}'),
          value: (stats?['uniqueBarbers'] ?? 0).toString(),
          label: 'Barberos',
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: 150.ms)
            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 300.ms, delay: 150.ms),
      ],
    );
  }
}

