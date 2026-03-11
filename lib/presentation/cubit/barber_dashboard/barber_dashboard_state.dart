import 'package:equatable/equatable.dart';
import '../../../domain/entities/barber_dashboard_entity.dart';

enum DashboardPeriod { today, month }

class BarberDashboardState extends Equatable {
  // Period selection
  final DashboardPeriod period;
  final DateTime selectedDate;   // ← used when period == today
  final int selectedMonth;
  final int selectedYear;

  // Loading flags
  final bool isDailyLoading;
  final bool isMonthlyLoading;
  final bool isRevenueChartLoading;
  final bool isTopServicesLoading;
  final bool isClientsLoading;
  final bool isPromotionsLoading;
  final bool isProfileViewsLoading;
  final bool isPeakHoursLoading;
  final bool isRatingTrendLoading;
  final bool isPaymentMethodsLoading;
  final bool isReviewDistributionLoading;
  final bool isWeekdayRevenueLoading;

  // Data
  final DailySummaryEntity? dailySummary;
  final MonthlySummaryEntity? monthlySummary;
  final List<RevenueChartPoint> revenueChart;
  final List<DashboardTopService> topServices;
  final ClientStatsEntity? clientStats;
  final List<PromotionStatEntity> promotionStats;
  final ProfileViewsEntity? profileViews;
  final List<PeakHourEntity> peakHours;
  final List<RatingTrendPoint> ratingTrend;
  final List<PaymentMethodStatEntity> paymentMethods;
  final List<ReviewDistributionEntity> reviewDistribution;
  final List<RevenueByWeekdayEntity> weekdayRevenue;

  // Errors
  final String? dailyError;
  final String? monthlyError;
  final String? generalError;

  BarberDashboardState({
    this.period = DashboardPeriod.today,            // ← default: Hoy
    DateTime? selectedDate,
    int? selectedMonth,
    int? selectedYear,
    this.isDailyLoading = false,
    this.isMonthlyLoading = false,
    this.isRevenueChartLoading = false,
    this.isTopServicesLoading = false,
    this.isClientsLoading = false,
    this.isPromotionsLoading = false,
    this.isProfileViewsLoading = false,
    this.isPeakHoursLoading = false,
    this.isRatingTrendLoading = false,
    this.isPaymentMethodsLoading = false,
    this.isReviewDistributionLoading = false,
    this.isWeekdayRevenueLoading = false,
    this.dailySummary,
    this.monthlySummary,
    this.revenueChart = const [],
    this.topServices = const [],
    this.clientStats,
    this.promotionStats = const [],
    this.profileViews,
    this.peakHours = const [],
    this.ratingTrend = const [],
    this.paymentMethods = const [],
    this.reviewDistribution = const [],
    this.weekdayRevenue = const [],
    this.dailyError,
    this.monthlyError,
    this.generalError,
  })  : selectedDate = selectedDate ?? DateTime.now(),
        selectedMonth = selectedMonth ?? DateTime.now().month,
        selectedYear = selectedYear ?? DateTime.now().year;

  bool get isAnyLoading =>
      isDailyLoading ||
      isMonthlyLoading ||
      isRevenueChartLoading ||
      isTopServicesLoading ||
      isClientsLoading ||
      isPromotionsLoading ||
      isProfileViewsLoading ||
      isPeakHoursLoading ||
      isRatingTrendLoading ||
      isPaymentMethodsLoading ||
      isReviewDistributionLoading ||
      isWeekdayRevenueLoading;

  /// True when selectedDate is today's date
  bool get isToday {
    final now = DateTime.now();
    return selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
  }

  BarberDashboardState copyWith({
    DashboardPeriod? period,
    DateTime? selectedDate,
    int? selectedMonth,
    int? selectedYear,
    bool? isDailyLoading,
    bool? isMonthlyLoading,
    bool? isRevenueChartLoading,
    bool? isTopServicesLoading,
    bool? isClientsLoading,
    bool? isPromotionsLoading,
    bool? isProfileViewsLoading,
    bool? isPeakHoursLoading,
    bool? isRatingTrendLoading,
    bool? isPaymentMethodsLoading,
    bool? isReviewDistributionLoading,
    bool? isWeekdayRevenueLoading,
    DailySummaryEntity? dailySummary,
    MonthlySummaryEntity? monthlySummary,
    List<RevenueChartPoint>? revenueChart,
    List<DashboardTopService>? topServices,
    ClientStatsEntity? clientStats,
    List<PromotionStatEntity>? promotionStats,
    ProfileViewsEntity? profileViews,
    List<PeakHourEntity>? peakHours,
    List<RatingTrendPoint>? ratingTrend,
    List<PaymentMethodStatEntity>? paymentMethods,
    List<ReviewDistributionEntity>? reviewDistribution,
    List<RevenueByWeekdayEntity>? weekdayRevenue,
    String? dailyError,
    String? monthlyError,
    String? generalError,
  }) {
    return BarberDashboardState(
      period: period ?? this.period,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedYear: selectedYear ?? this.selectedYear,
      isDailyLoading: isDailyLoading ?? this.isDailyLoading,
      isMonthlyLoading: isMonthlyLoading ?? this.isMonthlyLoading,
      isRevenueChartLoading: isRevenueChartLoading ?? this.isRevenueChartLoading,
      isTopServicesLoading: isTopServicesLoading ?? this.isTopServicesLoading,
      isClientsLoading: isClientsLoading ?? this.isClientsLoading,
      isPromotionsLoading: isPromotionsLoading ?? this.isPromotionsLoading,
      isProfileViewsLoading: isProfileViewsLoading ?? this.isProfileViewsLoading,
      isPeakHoursLoading: isPeakHoursLoading ?? this.isPeakHoursLoading,
      isRatingTrendLoading: isRatingTrendLoading ?? this.isRatingTrendLoading,
      isPaymentMethodsLoading: isPaymentMethodsLoading ?? this.isPaymentMethodsLoading,
      isReviewDistributionLoading: isReviewDistributionLoading ?? this.isReviewDistributionLoading,
      isWeekdayRevenueLoading: isWeekdayRevenueLoading ?? this.isWeekdayRevenueLoading,
      dailySummary: dailySummary ?? this.dailySummary,
      monthlySummary: monthlySummary ?? this.monthlySummary,
      revenueChart: revenueChart ?? this.revenueChart,
      topServices: topServices ?? this.topServices,
      clientStats: clientStats ?? this.clientStats,
      promotionStats: promotionStats ?? this.promotionStats,
      profileViews: profileViews ?? this.profileViews,
      peakHours: peakHours ?? this.peakHours,
      ratingTrend: ratingTrend ?? this.ratingTrend,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      reviewDistribution: reviewDistribution ?? this.reviewDistribution,
      weekdayRevenue: weekdayRevenue ?? this.weekdayRevenue,
      dailyError: dailyError ?? this.dailyError,
      monthlyError: monthlyError ?? this.monthlyError,
      generalError: generalError ?? this.generalError,
    );
  }

  @override
  List<Object?> get props => [
        period, selectedDate, selectedMonth, selectedYear,
        isDailyLoading, isMonthlyLoading, isRevenueChartLoading,
        isTopServicesLoading, isClientsLoading, isPromotionsLoading,
        isProfileViewsLoading, isPeakHoursLoading, isRatingTrendLoading,
        isPaymentMethodsLoading, isReviewDistributionLoading, isWeekdayRevenueLoading,
        dailySummary, monthlySummary, revenueChart, topServices,
        clientStats, promotionStats, profileViews, peakHours,
        ratingTrend, paymentMethods, reviewDistribution, weekdayRevenue,
        dailyError, monthlyError, generalError,
      ];
}
