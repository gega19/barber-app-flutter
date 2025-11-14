import '../../../data/models/promotion_model.dart';
import 'barber_utils.dart';

/// Utilidades para operaciones relacionadas con promociones
class PromotionUtils {
  /// Obtiene el texto del descuento formateado
  static String getDiscountText(PromotionModel promotion) {
    if (promotion.discount != null) {
      return '${promotion.discount!.toStringAsFixed(0)}% OFF';
    } else if (promotion.discountAmount != null) {
      return '\$${promotion.discountAmount!.toStringAsFixed(0)} OFF';
    }
    return '';
  }

  /// Formatea la fecha de validez de la promoción
  static String formatValidUntil(PromotionModel promotion) {
    return BarberUtils.formatDate(promotion.validUntil);
  }

  /// Verifica si una promoción está activa
  static bool isActive(PromotionModel promotion) {
    final now = DateTime.now();
    return promotion.isActive &&
        promotion.validFrom.isBefore(now) &&
        promotion.validUntil.isAfter(now);
  }
}

