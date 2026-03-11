import 'package:flutter_bloc/flutter_bloc.dart';
import 'barber_dashboard_state.dart';
import '../../../domain/usecases/barber/barber_dashboard_usecases.dart';

class BarberDashboardCubit extends Cubit<BarberDashboardState> {
  final GetDailySummaryUseCase getDailySummary;
  final GetMonthlySummaryUseCase getMonthlySummary;
  final GetRevenueChartUseCase getRevenueChart;
  final GetTopServicesUseCase getTopServices;
  final GetClientStatsUseCase getClientStats;
  final GetPromotionStatsUseCase getPromotionStats;
  final GetProfileViewsUseCase getProfileViews;
  final GetPeakHoursUseCase getPeakHours;
  final GetRatingTrendUseCase getRatingTrend;
  final GetRevenueByPaymentMethodUseCase getRevenueByPaymentMethod;
  final GetReviewDistributionUseCase getReviewDistribution;
  final GetRevenueByWeekdayUseCase getRevenueByWeekday;

  BarberDashboardCubit({
    required this.getDailySummary,
    required this.getMonthlySummary,
    required this.getRevenueChart,
    required this.getTopServices,
    required this.getClientStats,
    required this.getPromotionStats,
    required this.getProfileViews,
    required this.getPeakHours,
    required this.getRatingTrend,
    required this.getRevenueByPaymentMethod,
    required this.getReviewDistribution,
    required this.getRevenueByWeekday,
  }) : super(
         BarberDashboardState(),
       ); // defaults: period=today, selectedDate=now

  // ─── Public API ───────────────────────────────────────────────────

  /// Initial full load
  Future<void> loadDashboard(String barberId) async {
    _emitAllLoading();

    final date = state.selectedDate;
    final month = state.selectedMonth;
    final year = state.selectedYear;

    final results = await Future.wait([
      getDailySummary(barberId, date: _dateStr(date)), // 0
      getMonthlySummary(barberId, month: month, year: year), // 1
      getRevenueChart(barberId, period: 'monthly'), // 2
      getTopServices(barberId, month: month, year: year), // 3
      getClientStats(barberId, month: month, year: year), // 4
      getPromotionStats(barberId, month: month, year: year), // 5
      getProfileViews(barberId, days: 30), // 6
      getPeakHours(barberId, month: month, year: year), // 7
      getRatingTrend(barberId), // 8
      getRevenueByPaymentMethod(barberId, month: month, year: year), // 9
      getReviewDistribution(barberId), // 10
      getRevenueByWeekday(barberId, month: month, year: year), // 11
    ]);

    _emitResults(results);
  }

  /// Switch period (today / month) and reload
  Future<void> setPeriod(String barberId, DashboardPeriod period) async {
    emit(state.copyWith(period: period));
    await loadDashboard(barberId);
  }

  /// Navigate to a specific day (and switch to "today" period)
  Future<void> setDay(String barberId, DateTime date) async {
    // Never allow going past today
    final today = DateTime.now();
    final clamped = date.isAfter(today)
        ? DateTime(today.year, today.month, today.day)
        : DateTime(date.year, date.month, date.day);

    emit(state.copyWith(period: DashboardPeriod.today, selectedDate: clamped));
    await _reloadDaily(barberId, clamped);
  }

  /// Go one day back
  Future<void> previousDay(String barberId) {
    final prev = state.selectedDate.subtract(const Duration(days: 1));
    return setDay(barberId, prev);
  }

  /// Go one day forward (capped at today)
  Future<void> nextDay(String barberId) {
    final next = state.selectedDate.add(const Duration(days: 1));
    return setDay(barberId, next);
  }

  /// Change month/year for the monthly view
  Future<void> setMonth(String barberId, int month, int year) async {
    emit(
      state.copyWith(
        period: DashboardPeriod.month,
        selectedMonth: month,
        selectedYear: year,
      ),
    );
    await loadDashboard(barberId);
  }

  /// Go one month back
  Future<void> previousMonth(String barberId) {
    int m = state.selectedMonth - 1;
    int y = state.selectedYear;
    if (m < 1) {
      m = 12;
      y--;
    }
    return setMonth(barberId, m, y);
  }

  /// Go one month forward (capped at current month)
  Future<void> nextMonth(String barberId) {
    final now = DateTime.now();
    int m = state.selectedMonth + 1;
    int y = state.selectedYear;
    if (m > 12) {
      m = 1;
      y++;
    }
    // Don't go past current month
    if (y > now.year || (y == now.year && m > now.month)) return Future.value();
    return setMonth(barberId, m, y);
  }

  // ─── Private helpers ─────────────────────────────────────────────

  /// Reload only the daily slice (fast, single request)
  Future<void> _reloadDaily(String barberId, DateTime date) async {
    emit(state.copyWith(isDailyLoading: true));
    final result = await getDailySummary(barberId, date: _dateStr(date));
    emit(
      state.copyWith(
        isDailyLoading: false,
        dailySummary: result.fold((_) => null, (r) => r),
      ),
    );
  }

  void _emitAllLoading() {
    emit(
      state.copyWith(
        isDailyLoading: true,
        isMonthlyLoading: true,
        isRevenueChartLoading: true,
        isTopServicesLoading: true,
        isClientsLoading: true,
        isPromotionsLoading: true,
        isProfileViewsLoading: true,
        isPeakHoursLoading: true,
        isRatingTrendLoading: true,
        isPaymentMethodsLoading: true,
        isReviewDistributionLoading: true,
        isWeekdayRevenueLoading: true,
      ),
    );
  }

  void _emitResults(List<dynamic> results) {
    emit(
      state.copyWith(
        isDailyLoading: false,
        isMonthlyLoading: false,
        isRevenueChartLoading: false,
        isTopServicesLoading: false,
        isClientsLoading: false,
        isPromotionsLoading: false,
        isProfileViewsLoading: false,
        isPeakHoursLoading: false,
        isRatingTrendLoading: false,
        isPaymentMethodsLoading: false,
        isReviewDistributionLoading: false,
        isWeekdayRevenueLoading: false,
        dailySummary: results[0].fold((_) => null, (r) => r) as dynamic,
        monthlySummary: results[1].fold((_) => null, (r) => r) as dynamic,
        revenueChart: results[2].fold((_) => [], (r) => r) as dynamic,
        topServices: results[3].fold((_) => [], (r) => r) as dynamic,
        clientStats: results[4].fold((_) => null, (r) => r) as dynamic,
        promotionStats: results[5].fold((_) => [], (r) => r) as dynamic,
        profileViews: results[6].fold((_) => null, (r) => r) as dynamic,
        peakHours: results[7].fold((_) => [], (r) => r) as dynamic,
        ratingTrend: results[8].fold((_) => [], (r) => r) as dynamic,
        paymentMethods: results[9].fold((_) => [], (r) => r) as dynamic,
        reviewDistribution: results[10].fold((_) => [], (r) => r) as dynamic,
        weekdayRevenue: results[11].fold((_) => [], (r) => r) as dynamic,
      ),
    );
  }

  String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
