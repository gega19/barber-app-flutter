import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../entities/barber_dashboard_entity.dart';

abstract class BarberDashboardRepository {
  Future<Either<Failure, DailySummaryEntity>> getDailySummary(String barberId, {String? date});
  Future<Either<Failure, MonthlySummaryEntity>> getMonthlySummary(String barberId, {int? month, int? year});
  Future<Either<Failure, List<RevenueChartPoint>>> getRevenueChart(String barberId, {String period = 'monthly'});
  Future<Either<Failure, List<DashboardTopService>>> getTopServices(String barberId, {int? month, int? year});
  Future<Either<Failure, ClientStatsEntity>> getClientStats(String barberId, {int? month, int? year});
  Future<Either<Failure, List<PromotionStatEntity>>> getPromotionStats(String barberId, {int? month, int? year});
  Future<Either<Failure, ProfileViewsEntity>> getProfileViews(String barberId, {int days = 30});
  Future<Either<Failure, List<PeakHourEntity>>> getPeakHours(String barberId, {int? month, int? year});
  Future<Either<Failure, List<RatingTrendPoint>>> getRatingTrend(String barberId);
  Future<Either<Failure, List<PaymentMethodStatEntity>>> getRevenueByPaymentMethod(String barberId, {int? month, int? year});
  Future<Either<Failure, List<ReviewDistributionEntity>>> getReviewDistribution(String barberId);
  Future<Either<Failure, List<RevenueByWeekdayEntity>>> getRevenueByWeekday(String barberId, {int? month, int? year});
}
