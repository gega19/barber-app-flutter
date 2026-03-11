import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/barber_dashboard_entity.dart';
import '../../repositories/barber_dashboard_repository.dart';

/// Obtiene el resumen del día para un barbero
class GetDailySummaryUseCase {
  final BarberDashboardRepository repository;
  GetDailySummaryUseCase(this.repository);

  Future<Either<Failure, DailySummaryEntity>> call(String barberId, {String? date}) =>
      repository.getDailySummary(barberId, date: date);
}

/// Obtiene el resumen mensual para un barbero
class GetMonthlySummaryUseCase {
  final BarberDashboardRepository repository;
  GetMonthlySummaryUseCase(this.repository);

  Future<Either<Failure, MonthlySummaryEntity>> call(String barberId, {int? month, int? year}) =>
      repository.getMonthlySummary(barberId, month: month, year: year);
}

/// Obtiene el gráfico de ingresos (semanal o mensual)
class GetRevenueChartUseCase {
  final BarberDashboardRepository repository;
  GetRevenueChartUseCase(this.repository);

  Future<Either<Failure, List<RevenueChartPoint>>> call(String barberId, {String period = 'monthly'}) =>
      repository.getRevenueChart(barberId, period: period);
}

/// Obtiene los servicios más vendidos
class GetTopServicesUseCase {
  final BarberDashboardRepository repository;
  GetTopServicesUseCase(this.repository);

  Future<Either<Failure, List<DashboardTopService>>> call(String barberId, {int? month, int? year}) =>
      repository.getTopServices(barberId, month: month, year: year);
}

/// Obtiene estadísticas de clientes (nuevos vs fieles, en riesgo, top)
class GetClientStatsUseCase {
  final BarberDashboardRepository repository;
  GetClientStatsUseCase(this.repository);

  Future<Either<Failure, ClientStatsEntity>> call(String barberId, {int? month, int? year}) =>
      repository.getClientStats(barberId, month: month, year: year);
}

/// Obtiene rendimiento de promociones
class GetPromotionStatsUseCase {
  final BarberDashboardRepository repository;
  GetPromotionStatsUseCase(this.repository);

  Future<Either<Failure, List<PromotionStatEntity>>> call(String barberId, {int? month, int? year}) =>
      repository.getPromotionStats(barberId, month: month, year: year);
}

/// Obtiene vistas del perfil público del barbero
class GetProfileViewsUseCase {
  final BarberDashboardRepository repository;
  GetProfileViewsUseCase(this.repository);

  Future<Either<Failure, ProfileViewsEntity>> call(String barberId, {int days = 30}) =>
      repository.getProfileViews(barberId, days: days);
}

/// Obtiene horarios pico de citas
class GetPeakHoursUseCase {
  final BarberDashboardRepository repository;
  GetPeakHoursUseCase(this.repository);

  Future<Either<Failure, List<PeakHourEntity>>> call(String barberId, {int? month, int? year}) =>
      repository.getPeakHours(barberId, month: month, year: year);
}

/// Obtiene la tendencia del rating en los últimos 6 meses
class GetRatingTrendUseCase {
  final BarberDashboardRepository repository;
  GetRatingTrendUseCase(this.repository);

  Future<Either<Failure, List<RatingTrendPoint>>> call(String barberId) =>
      repository.getRatingTrend(barberId);
}

/// Obtiene ingresos por método de pago
class GetRevenueByPaymentMethodUseCase {
  final BarberDashboardRepository repository;
  GetRevenueByPaymentMethodUseCase(this.repository);

  Future<Either<Failure, List<PaymentMethodStatEntity>>> call(String barberId, {int? month, int? year}) =>
      repository.getRevenueByPaymentMethod(barberId, month: month, year: year);
}

/// Obtiene la distribución de estrellas en reseñas
class GetReviewDistributionUseCase {
  final BarberDashboardRepository repository;
  GetReviewDistributionUseCase(this.repository);

  Future<Either<Failure, List<ReviewDistributionEntity>>> call(String barberId) =>
      repository.getReviewDistribution(barberId);
}

/// Obtiene ingresos por día de la semana
class GetRevenueByWeekdayUseCase {
  final BarberDashboardRepository repository;
  GetRevenueByWeekdayUseCase(this.repository);

  Future<Either<Failure, List<RevenueByWeekdayEntity>>> call(String barberId, {int? month, int? year}) =>
      repository.getRevenueByWeekday(barberId, month: month, year: year);
}
