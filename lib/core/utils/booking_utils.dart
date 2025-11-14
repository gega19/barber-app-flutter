import '../../data/models/service_model.dart';
import '../../data/models/promotion_model.dart';

/// Utilidades compartidas para el proceso de reserva/booking
class BookingUtils {
  /// Calcula el precio base del servicio
  static double calculateBasePrice({
    required ServiceModel? service,
    required double barberPrice,
  }) {
    if (service == null) {
      return barberPrice;
    }
    return service.price;
  }

  /// Calcula el monto de descuento basado en la promoción
  static double calculateDiscount({
    required double basePrice,
    PromotionModel? promotion,
  }) {
    if (promotion == null) return 0.0;

    if (promotion.discountAmount != null) {
      return promotion.discountAmount!;
    } else if (promotion.discount != null) {
      return basePrice * (promotion.discount! / 100);
    }
    return 0.0;
  }

  /// Calcula el precio final después de aplicar descuentos
  static double calculateTotalPrice({
    required double basePrice,
    required double discountAmount,
  }) {
    return basePrice - discountAmount;
  }

  /// Calcula el precio final completo (base, descuento y total)
  static Map<String, double> calculatePriceBreakdown({
    required ServiceModel? service,
    required double barberPrice,
    PromotionModel? promotion,
  }) {
    final basePrice = calculateBasePrice(
      service: service,
      barberPrice: barberPrice,
    );
    final discountAmount = calculateDiscount(
      basePrice: basePrice,
      promotion: promotion,
    );
    final totalPrice = calculateTotalPrice(
      basePrice: basePrice,
      discountAmount: discountAmount,
    );

    return {
      'basePrice': basePrice,
      'discountAmount': discountAmount,
      'totalPrice': totalPrice,
    };
  }

  /// Verifica si una fecha es válida para reservar (no puede ser en el pasado)
  static bool isValidBookingDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(date.year, date.month, date.day);
    return selectedDate.isAfter(today.subtract(const Duration(days: 1)));
  }

  /// Encuentra la primera promoción activa de una lista
  static PromotionModel? findActivePromotion(List<PromotionModel> promotions) {
    if (promotions.isEmpty) return null;
    
    final now = DateTime.now();
    // Obtener la primera promoción activa y válida
    try {
      return promotions.firstWhere(
        (p) => p.isActive &&
            p.validFrom.isBefore(now) &&
            p.validUntil.isAfter(now),
      );
    } catch (e) {
      // Si no hay promoción activa, retornar null
      return null;
    }
  }
}

