import '../../../domain/entities/workplace_entity.dart';
import '../constants/app_constants.dart';

/// Utilidades para trabajar con barberías
class WorkplaceUtils {
  /// Verifica si una barbería es "Top" basado en su rating
  static bool isTopWorkplace(WorkplaceEntity workplace) {
    return workplace.rating >= 4.8;
  }

  /// Formatea la calificación con reseñas
  static String formatRating(WorkplaceEntity workplace) {
    return '${workplace.rating.toStringAsFixed(1)} (${workplace.reviews} reseñas)';
  }

  /// Obtiene la URL completa de la imagen del banner
  static String getBannerUrl(WorkplaceEntity workplace) {
    if (workplace.banner != null && workplace.banner!.isNotEmpty) {
      return AppConstants.buildImageUrl(workplace.banner);
    }
    return 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=1200&h=600&fit=crop';
  }

  /// Obtiene la URL completa de la imagen del perfil
  static String getImageUrl(WorkplaceEntity workplace) {
    if (workplace.image != null && workplace.image!.isNotEmpty) {
      return AppConstants.buildImageUrl(workplace.image);
    }
    return 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=200&h=200&fit=crop';
  }
}

