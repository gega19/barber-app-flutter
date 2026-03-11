import 'package:equatable/equatable.dart';

// ─── Sub-entities ────────────────────────────────────────────────

class DailyAppointmentItem extends Equatable {
  final String id;
  final String time;
  final String status;
  final String clientName;
  final String? serviceName;
  final double? servicePrice;

  const DailyAppointmentItem({
    required this.id,
    required this.time,
    required this.status,
    required this.clientName,
    this.serviceName,
    this.servicePrice,
  });

  @override
  List<Object?> get props => [id, time, status, clientName, serviceName, servicePrice];
}

class DashboardTopService extends Equatable {
  final String serviceId;
  final String serviceName;
  final int count;
  final double revenue;
  final double percentage;

  const DashboardTopService({
    required this.serviceId,
    required this.serviceName,
    required this.count,
    required this.revenue,
    required this.percentage,
  });

  @override
  List<Object?> get props => [serviceId, serviceName, count, revenue, percentage];
}

class AtRiskClient extends Equatable {
  final String userId;
  final String clientName;
  final String lastVisit;
  final int daysSinceLastVisit;
  final int totalVisits;

  const AtRiskClient({
    required this.userId,
    required this.clientName,
    required this.lastVisit,
    required this.daysSinceLastVisit,
    required this.totalVisits,
  });

  @override
  List<Object?> get props => [userId, clientName, lastVisit, daysSinceLastVisit, totalVisits];
}

class TopClient extends Equatable {
  final String userId;
  final String clientName;
  final int totalVisits;
  final double totalSpent;
  final String lastVisit;

  const TopClient({
    required this.userId,
    required this.clientName,
    required this.totalVisits,
    required this.totalSpent,
    required this.lastVisit,
  });

  @override
  List<Object?> get props => [userId, clientName, totalVisits, totalSpent, lastVisit];
}

class PromotionStatEntity extends Equatable {
  final String promotionId;
  final String title;
  final String code;
  final double? discount;
  final double? discountAmount;
  final int usageCount;
  final bool isActive;
  final String validFrom;
  final String validUntil;

  const PromotionStatEntity({
    required this.promotionId,
    required this.title,
    required this.code,
    this.discount,
    this.discountAmount,
    required this.usageCount,
    required this.isActive,
    required this.validFrom,
    required this.validUntil,
  });

  @override
  List<Object?> get props => [promotionId, title, code, discount, discountAmount, usageCount, isActive];
}

class DailyViewData extends Equatable {
  final String date;
  final int count;

  const DailyViewData({required this.date, required this.count});

  @override
  List<Object?> get props => [date, count];
}

class PeakHourEntity extends Equatable {
  final String hour;
  final String displayHour;
  final int count;
  final double percentage;

  const PeakHourEntity({
    required this.hour,
    required this.displayHour,
    required this.count,
    required this.percentage,
  });

  @override
  List<Object?> get props => [hour, count, percentage];
}

class RatingTrendPoint extends Equatable {
  final String month;
  final double avgRating;
  final int reviewCount;

  const RatingTrendPoint({
    required this.month,
    required this.avgRating,
    required this.reviewCount,
  });

  @override
  List<Object?> get props => [month, avgRating, reviewCount];
}

class RevenueChartPoint extends Equatable {
  final String label;
  final double revenue;
  final int appointments;

  const RevenueChartPoint({
    required this.label,
    required this.revenue,
    required this.appointments,
  });

  @override
  List<Object?> get props => [label, revenue, appointments];
}

class RevenueByWeekdayEntity extends Equatable {
  final String dayName;
  final int dayIndex;
  final int count;
  final double revenue;

  const RevenueByWeekdayEntity({
    required this.dayName,
    required this.dayIndex,
    required this.count,
    required this.revenue,
  });

  @override
  List<Object?> get props => [dayName, dayIndex, count, revenue];
}

class ReviewDistributionEntity extends Equatable {
  final int stars;
  final int count;
  final double percentage;

  const ReviewDistributionEntity({
    required this.stars,
    required this.count,
    required this.percentage,
  });

  @override
  List<Object?> get props => [stars, count, percentage];
}

class PaymentMethodStatEntity extends Equatable {
  final String paymentMethod;
  final int count;
  final double revenue;
  final double percentage;

  const PaymentMethodStatEntity({
    required this.paymentMethod,
    required this.count,
    required this.revenue,
    required this.percentage,
  });

  @override
  List<Object?> get props => [paymentMethod, count, revenue, percentage];
}

// ─── Main Entities ────────────────────────────────────────────────

class DailySummaryEntity extends Equatable {
  final String date;
  final int totalAppointments;
  final int completed;
  final int pending;
  final int cancelled;
  final double revenue;
  final double avgTicket;
  final List<DailyAppointmentItem> appointments;

  const DailySummaryEntity({
    required this.date,
    required this.totalAppointments,
    required this.completed,
    required this.pending,
    required this.cancelled,
    required this.revenue,
    required this.avgTicket,
    required this.appointments,
  });

  @override
  List<Object?> get props => [date, totalAppointments, completed, pending, cancelled, revenue, avgTicket];
}

class MonthlySummaryEntity extends Equatable {
  final int month;
  final int year;
  final int totalAppointments;
  final int completed;
  final int cancelled;
  final int pending;
  final double revenue;
  final double avgTicket;
  final double cancellationRate;
  final double? revenueVsPrevMonth;
  final double? projectedRevenue;
  final int soldOutDays;
  final double occupancyRate;

  const MonthlySummaryEntity({
    required this.month,
    required this.year,
    required this.totalAppointments,
    required this.completed,
    required this.cancelled,
    required this.pending,
    required this.revenue,
    required this.avgTicket,
    required this.cancellationRate,
    this.revenueVsPrevMonth,
    this.projectedRevenue,
    required this.soldOutDays,
    required this.occupancyRate,
  });

  @override
  List<Object?> get props => [month, year, totalAppointments, revenue, cancellationRate];
}

class ClientStatsEntity extends Equatable {
  final int newClients;
  final int loyalClients;
  final int totalUniqueClients;
  final double? conversionRate;
  final double? avgRevisitDays;
  final List<AtRiskClient> atRiskClients;
  final List<TopClient> topClients;

  const ClientStatsEntity({
    required this.newClients,
    required this.loyalClients,
    required this.totalUniqueClients,
    this.conversionRate,
    this.avgRevisitDays,
    required this.atRiskClients,
    required this.topClients,
  });

  @override
  List<Object?> get props => [newClients, loyalClients, totalUniqueClients, conversionRate];
}

class ProfileViewsEntity extends Equatable {
  final int totalViews;
  final List<DailyViewData> dailyViews;

  const ProfileViewsEntity({
    required this.totalViews,
    required this.dailyViews,
  });

  @override
  List<Object?> get props => [totalViews, dailyViews];
}
