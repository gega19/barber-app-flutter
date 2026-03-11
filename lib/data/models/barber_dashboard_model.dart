import '../../domain/entities/barber_dashboard_entity.dart';

// ─── Model helpers ────────────────────────────────────────────────

class DailySummaryModel extends DailySummaryEntity {
  const DailySummaryModel({
    required super.date,
    required super.totalAppointments,
    required super.completed,
    required super.pending,
    required super.cancelled,
    required super.revenue,
    required super.avgTicket,
    required super.appointments,
  });

  factory DailySummaryModel.fromJson(Map<String, dynamic> json) {
    final items = (json['appointments'] as List? ?? [])
        .map((e) => DailyAppointmentItem(
              id: e['id'] as String,
              time: e['time'] as String,
              status: e['status'] as String,
              clientName: e['clientName'] as String? ?? 'Cliente',
              serviceName: e['serviceName'] as String?,
              servicePrice: (e['servicePrice'] as num?)?.toDouble(),
            ))
        .toList();

    return DailySummaryModel(
      date: json['date'] as String,
      totalAppointments: json['totalAppointments'] as int,
      completed: json['completed'] as int,
      pending: json['pending'] as int,
      cancelled: json['cancelled'] as int,
      revenue: (json['revenue'] as num).toDouble(),
      avgTicket: (json['avgTicket'] as num).toDouble(),
      appointments: items,
    );
  }
}

class MonthlySummaryModel extends MonthlySummaryEntity {
  const MonthlySummaryModel({
    required super.month,
    required super.year,
    required super.totalAppointments,
    required super.completed,
    required super.cancelled,
    required super.pending,
    required super.revenue,
    required super.avgTicket,
    required super.cancellationRate,
    super.revenueVsPrevMonth,
    super.projectedRevenue,
    required super.soldOutDays,
    required super.occupancyRate,
  });

  factory MonthlySummaryModel.fromJson(Map<String, dynamic> json) {
    return MonthlySummaryModel(
      month: json['month'] as int,
      year: json['year'] as int,
      totalAppointments: json['totalAppointments'] as int,
      completed: json['completed'] as int,
      cancelled: json['cancelled'] as int,
      pending: json['pending'] as int,
      revenue: (json['revenue'] as num).toDouble(),
      avgTicket: (json['avgTicket'] as num).toDouble(),
      cancellationRate: (json['cancellationRate'] as num).toDouble(),
      revenueVsPrevMonth: (json['revenueVsPrevMonth'] as num?)?.toDouble(),
      projectedRevenue: (json['projectedRevenue'] as num?)?.toDouble(),
      soldOutDays: json['soldOutDays'] as int,
      occupancyRate: (json['occupancyRate'] as num).toDouble(),
    );
  }
}

class RevenueChartPointModel extends RevenueChartPoint {
  const RevenueChartPointModel({
    required super.label,
    required super.revenue,
    required super.appointments,
  });

  factory RevenueChartPointModel.fromJson(Map<String, dynamic> json) {
    return RevenueChartPointModel(
      label: json['label'] as String,
      revenue: (json['revenue'] as num).toDouble(),
      appointments: json['appointments'] as int,
    );
  }
}

class DashboardTopServiceModel extends DashboardTopService {
  const DashboardTopServiceModel({
    required super.serviceId,
    required super.serviceName,
    required super.count,
    required super.revenue,
    required super.percentage,
  });

  factory DashboardTopServiceModel.fromJson(Map<String, dynamic> json) {
    return DashboardTopServiceModel(
      serviceId: json['serviceId'] as String,
      serviceName: json['serviceName'] as String,
      count: json['count'] as int,
      revenue: (json['revenue'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}

class ClientStatsModel extends ClientStatsEntity {
  const ClientStatsModel({
    required super.newClients,
    required super.loyalClients,
    required super.totalUniqueClients,
    super.conversionRate,
    super.avgRevisitDays,
    required super.atRiskClients,
    required super.topClients,
  });

  factory ClientStatsModel.fromJson(Map<String, dynamic> json) {
    final atRisk = (json['atRiskClients'] as List? ?? [])
        .map((e) => AtRiskClient(
              userId: e['userId'] as String,
              clientName: e['clientName'] as String,
              lastVisit: e['lastVisit'] as String,
              daysSinceLastVisit: e['daysSinceLastVisit'] as int,
              totalVisits: e['totalVisits'] as int,
            ))
        .toList();

    final top = (json['topClients'] as List? ?? [])
        .map((e) => TopClient(
              userId: e['userId'] as String,
              clientName: e['clientName'] as String,
              totalVisits: e['totalVisits'] as int,
              totalSpent: (e['totalSpent'] as num).toDouble(),
              lastVisit: e['lastVisit'] as String,
            ))
        .toList();

    return ClientStatsModel(
      newClients: json['newClients'] as int,
      loyalClients: json['loyalClients'] as int,
      totalUniqueClients: json['totalUniqueClients'] as int,
      conversionRate: (json['conversionRate'] as num?)?.toDouble(),
      avgRevisitDays: (json['avgRevisitDays'] as num?)?.toDouble(),
      atRiskClients: atRisk,
      topClients: top,
    );
  }
}

class PromotionStatModel extends PromotionStatEntity {
  const PromotionStatModel({
    required super.promotionId,
    required super.title,
    required super.code,
    super.discount,
    super.discountAmount,
    required super.usageCount,
    required super.isActive,
    required super.validFrom,
    required super.validUntil,
  });

  factory PromotionStatModel.fromJson(Map<String, dynamic> json) {
    return PromotionStatModel(
      promotionId: json['promotionId'] as String,
      title: json['title'] as String,
      code: json['code'] as String,
      discount: (json['discount'] as num?)?.toDouble(),
      discountAmount: (json['discountAmount'] as num?)?.toDouble(),
      usageCount: json['usageCount'] as int,
      isActive: json['isActive'] as bool,
      validFrom: json['validFrom'] as String,
      validUntil: json['validUntil'] as String,
    );
  }
}

class ProfileViewsModel extends ProfileViewsEntity {
  const ProfileViewsModel({
    required super.totalViews,
    required super.dailyViews,
  });

  factory ProfileViewsModel.fromJson(Map<String, dynamic> json) {
    final daily = (json['dailyViews'] as List? ?? [])
        .map((e) => DailyViewData(
              date: e['date'] as String,
              count: e['count'] as int,
            ))
        .toList();

    return ProfileViewsModel(
      totalViews: json['totalViews'] as int,
      dailyViews: daily,
    );
  }
}

class PeakHourModel extends PeakHourEntity {
  const PeakHourModel({
    required super.hour,
    required super.displayHour,
    required super.count,
    required super.percentage,
  });

  factory PeakHourModel.fromJson(Map<String, dynamic> json) {
    return PeakHourModel(
      hour: json['hour'] as String,
      displayHour: json['displayHour'] as String,
      count: json['count'] as int,
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}

class RatingTrendPointModel extends RatingTrendPoint {
  const RatingTrendPointModel({
    required super.month,
    required super.avgRating,
    required super.reviewCount,
  });

  factory RatingTrendPointModel.fromJson(Map<String, dynamic> json) {
    return RatingTrendPointModel(
      month: json['month'] as String,
      avgRating: (json['avgRating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
    );
  }
}

class RevenueByWeekdayModel extends RevenueByWeekdayEntity {
  const RevenueByWeekdayModel({
    required super.dayName,
    required super.dayIndex,
    required super.count,
    required super.revenue,
  });

  factory RevenueByWeekdayModel.fromJson(Map<String, dynamic> json) {
    return RevenueByWeekdayModel(
      dayName: json['dayName'] as String,
      dayIndex: json['dayIndex'] as int,
      count: json['count'] as int,
      revenue: (json['revenue'] as num).toDouble(),
    );
  }
}

class ReviewDistributionModel extends ReviewDistributionEntity {
  const ReviewDistributionModel({
    required super.stars,
    required super.count,
    required super.percentage,
  });

  factory ReviewDistributionModel.fromJson(Map<String, dynamic> json) {
    return ReviewDistributionModel(
      stars: json['stars'] as int,
      count: json['count'] as int,
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}

class PaymentMethodStatModel extends PaymentMethodStatEntity {
  const PaymentMethodStatModel({
    required super.paymentMethod,
    required super.count,
    required super.revenue,
    required super.percentage,
  });

  factory PaymentMethodStatModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodStatModel(
      paymentMethod: json['paymentMethod'] as String,
      count: json['count'] as int,
      revenue: (json['revenue'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}
