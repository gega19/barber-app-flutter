import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import '../../models/barber_dashboard_model.dart';
import 'package:dio/dio.dart';

abstract class BarberDashboardRemoteDataSource {
  Future<DailySummaryModel> getDailySummary(String barberId, {String? date});
  Future<MonthlySummaryModel> getMonthlySummary(String barberId, {int? month, int? year});
  Future<List<RevenueChartPointModel>> getRevenueChart(String barberId, {String period = 'monthly'});
  Future<List<DashboardTopServiceModel>> getTopServices(String barberId, {int? month, int? year, int limit = 5});
  Future<ClientStatsModel> getClientStats(String barberId, {int? month, int? year});
  Future<List<PromotionStatModel>> getPromotionStats(String barberId, {int? month, int? year});
  Future<ProfileViewsModel> getProfileViews(String barberId, {int days = 30});
  Future<List<PeakHourModel>> getPeakHours(String barberId, {int? month, int? year});
  Future<List<RatingTrendPointModel>> getRatingTrend(String barberId);
  Future<List<PaymentMethodStatModel>> getRevenueByPaymentMethod(String barberId, {int? month, int? year});
  Future<List<ReviewDistributionModel>> getReviewDistribution(String barberId);
  Future<List<RevenueByWeekdayModel>> getRevenueByWeekday(String barberId, {int? month, int? year});
}

class BarberDashboardRemoteDataSourceImpl implements BarberDashboardRemoteDataSource {
  final Dio dio;
  final String _base;

  BarberDashboardRemoteDataSourceImpl(this.dio)
      : _base = '${AppConstants.baseUrl}/api/barber-dashboard';

  Map<String, dynamic> _monthYearParams({int? month, int? year}) {
    final now = DateTime.now();
    return {
      'month': month ?? now.month,
      'year': year ?? now.year,
    };
  }

  dynamic _data(Response response) => response.data['data'];

  @override
  Future<DailySummaryModel> getDailySummary(String barberId, {String? date}) async {
    try {
      final response = await dio.get(
        '$_base/$barberId/daily',
        queryParameters: date != null ? {'date': date} : null,
      );
      return DailySummaryModel.fromJson(_data(response));
    } on DioException catch (e) {
      appLogger.e('getDailySummary error: ${e.message}', error: e);
      throw Exception('Error al obtener resumen del día: ${e.message}');
    }
  }

  @override
  Future<MonthlySummaryModel> getMonthlySummary(String barberId, {int? month, int? year}) async {
    try {
      final response = await dio.get(
        '$_base/$barberId/monthly',
        queryParameters: _monthYearParams(month: month, year: year),
      );
      return MonthlySummaryModel.fromJson(_data(response));
    } on DioException catch (e) {
      appLogger.e('getMonthlySummary error: ${e.message}', error: e);
      throw Exception('Error al obtener resumen mensual: ${e.message}');
    }
  }

  @override
  Future<List<RevenueChartPointModel>> getRevenueChart(String barberId, {String period = 'monthly'}) async {
    try {
      final response = await dio.get(
        '$_base/$barberId/revenue-chart',
        queryParameters: {'period': period},
      );
      return (_data(response) as List)
          .map((e) => RevenueChartPointModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      appLogger.e('getRevenueChart error: ${e.message}', error: e);
      throw Exception('Error al obtener gráfico de ingresos: ${e.message}');
    }
  }

  @override
  Future<List<DashboardTopServiceModel>> getTopServices(
    String barberId, {int? month, int? year, int limit = 5}) async {
    try {
      final params = {'limit': limit, ..._monthYearParams(month: month, year: year)};
      final response = await dio.get('$_base/$barberId/top-services', queryParameters: params);
      return (_data(response) as List)
          .map((e) => DashboardTopServiceModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      appLogger.e('getTopServices error: ${e.message}', error: e);
      throw Exception('Error al obtener top servicios: ${e.message}');
    }
  }

  @override
  Future<ClientStatsModel> getClientStats(String barberId, {int? month, int? year}) async {
    try {
      final response = await dio.get(
        '$_base/$barberId/clients',
        queryParameters: _monthYearParams(month: month, year: year),
      );
      return ClientStatsModel.fromJson(_data(response));
    } on DioException catch (e) {
      appLogger.e('getClientStats error: ${e.message}', error: e);
      throw Exception('Error al obtener estadísticas de clientes: ${e.message}');
    }
  }

  @override
  Future<List<PromotionStatModel>> getPromotionStats(String barberId, {int? month, int? year}) async {
    try {
      final response = await dio.get(
        '$_base/$barberId/promotions',
        queryParameters: _monthYearParams(month: month, year: year),
      );
      return (_data(response) as List)
          .map((e) => PromotionStatModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      appLogger.e('getPromotionStats error: ${e.message}', error: e);
      throw Exception('Error al obtener estadísticas de promociones: ${e.message}');
    }
  }

  @override
  Future<ProfileViewsModel> getProfileViews(String barberId, {int days = 30}) async {
    try {
      final response = await dio.get(
        '$_base/$barberId/profile-views',
        queryParameters: {'days': days},
      );
      return ProfileViewsModel.fromJson(_data(response));
    } on DioException catch (e) {
      appLogger.e('getProfileViews error: ${e.message}', error: e);
      throw Exception('Error al obtener vistas del perfil: ${e.message}');
    }
  }

  @override
  Future<List<PeakHourModel>> getPeakHours(String barberId, {int? month, int? year}) async {
    try {
      final response = await dio.get(
        '$_base/$barberId/peak-hours',
        queryParameters: _monthYearParams(month: month, year: year),
      );
      return (_data(response) as List)
          .map((e) => PeakHourModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      appLogger.e('getPeakHours error: ${e.message}', error: e);
      throw Exception('Error al obtener horarios pico: ${e.message}');
    }
  }

  @override
  Future<List<RatingTrendPointModel>> getRatingTrend(String barberId) async {
    try {
      final response = await dio.get('$_base/$barberId/rating-trend');
      return (_data(response) as List)
          .map((e) => RatingTrendPointModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      appLogger.e('getRatingTrend error: ${e.message}', error: e);
      throw Exception('Error al obtener tendencia del rating: ${e.message}');
    }
  }

  @override
  Future<List<PaymentMethodStatModel>> getRevenueByPaymentMethod(
    String barberId, {int? month, int? year}) async {
    try {
      final response = await dio.get(
        '$_base/$barberId/payment-methods',
        queryParameters: _monthYearParams(month: month, year: year),
      );
      return (_data(response) as List)
          .map((e) => PaymentMethodStatModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      appLogger.e('getRevenueByPaymentMethod error: ${e.message}', error: e);
      throw Exception('Error al obtener datos de métodos de pago: ${e.message}');
    }
  }

  @override
  Future<List<ReviewDistributionModel>> getReviewDistribution(String barberId) async {
    try {
      final response = await dio.get('$_base/$barberId/reviews/distribution');
      return (_data(response) as List)
          .map((e) => ReviewDistributionModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      appLogger.e('getReviewDistribution error: ${e.message}', error: e);
      throw Exception('Error al obtener distribución de reseñas: ${e.message}');
    }
  }

  @override
  Future<List<RevenueByWeekdayModel>> getRevenueByWeekday(
    String barberId, {int? month, int? year}) async {
    try {
      final response = await dio.get(
        '$_base/$barberId/revenue-by-weekday',
        queryParameters: _monthYearParams(month: month, year: year),
      );
      return (_data(response) as List)
          .map((e) => RevenueByWeekdayModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      appLogger.e('getRevenueByWeekday error: ${e.message}', error: e);
      throw Exception('Error al obtener ingresos por día de semana: ${e.message}');
    }
  }
}
