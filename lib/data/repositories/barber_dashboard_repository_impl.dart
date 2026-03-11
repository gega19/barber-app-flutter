import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../datasources/remote/barber_dashboard_remote_datasource.dart';
import '../../../domain/entities/barber_dashboard_entity.dart';
import '../../../domain/repositories/barber_dashboard_repository.dart';

class BarberDashboardRepositoryImpl implements BarberDashboardRepository {
  final BarberDashboardRemoteDataSource remoteDataSource;

  BarberDashboardRepositoryImpl(this.remoteDataSource);

  Future<Either<Failure, T>> _call<T>(Future<T> Function() fn) async {
    try {
      return Right(await fn());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DailySummaryEntity>> getDailySummary(String barberId, {String? date}) =>
      _call(() => remoteDataSource.getDailySummary(barberId, date: date));

  @override
  Future<Either<Failure, MonthlySummaryEntity>> getMonthlySummary(String barberId, {int? month, int? year}) =>
      _call(() => remoteDataSource.getMonthlySummary(barberId, month: month, year: year));

  @override
  Future<Either<Failure, List<RevenueChartPoint>>> getRevenueChart(String barberId, {String period = 'monthly'}) =>
      _call(() => remoteDataSource.getRevenueChart(barberId, period: period));

  @override
  Future<Either<Failure, List<DashboardTopService>>> getTopServices(String barberId, {int? month, int? year}) =>
      _call(() => remoteDataSource.getTopServices(barberId, month: month, year: year));

  @override
  Future<Either<Failure, ClientStatsEntity>> getClientStats(String barberId, {int? month, int? year}) =>
      _call(() => remoteDataSource.getClientStats(barberId, month: month, year: year));

  @override
  Future<Either<Failure, List<PromotionStatEntity>>> getPromotionStats(String barberId, {int? month, int? year}) =>
      _call(() => remoteDataSource.getPromotionStats(barberId, month: month, year: year));

  @override
  Future<Either<Failure, ProfileViewsEntity>> getProfileViews(String barberId, {int days = 30}) =>
      _call(() => remoteDataSource.getProfileViews(barberId, days: days));

  @override
  Future<Either<Failure, List<PeakHourEntity>>> getPeakHours(String barberId, {int? month, int? year}) =>
      _call(() => remoteDataSource.getPeakHours(barberId, month: month, year: year));

  @override
  Future<Either<Failure, List<RatingTrendPoint>>> getRatingTrend(String barberId) =>
      _call(() => remoteDataSource.getRatingTrend(barberId));

  @override
  Future<Either<Failure, List<PaymentMethodStatEntity>>> getRevenueByPaymentMethod(String barberId, {int? month, int? year}) =>
      _call(() => remoteDataSource.getRevenueByPaymentMethod(barberId, month: month, year: year));

  @override
  Future<Either<Failure, List<ReviewDistributionEntity>>> getReviewDistribution(String barberId) =>
      _call(() => remoteDataSource.getReviewDistribution(barberId));

  @override
  Future<Either<Failure, List<RevenueByWeekdayEntity>>> getRevenueByWeekday(String barberId, {int? month, int? year}) =>
      _call(() => remoteDataSource.getRevenueByWeekday(barberId, month: month, year: year));
}
