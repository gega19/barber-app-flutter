import '../../../domain/entities/barber_entity.dart';
import '../../../domain/entities/workplace_entity.dart';
import '../constants/home_constants.dart';

/// Utilidades para filtrar y ordenar listas
class FilterUtils {
  FilterUtils._();

  /// Filtra barberos por búsqueda
  static List<BarberEntity> filterBarbersBySearch(
    List<BarberEntity> barbers,
    String query,
  ) {
    if (query.isEmpty) {
      return barbers;
    }

    final lowerQuery = query.toLowerCase();
    return barbers.where((barber) {
      final nameMatch = barber.name.toLowerCase().contains(lowerQuery);
      final locationMatch = barber.location.toLowerCase().contains(lowerQuery);
      final specialtyMatch = barber.specialty.toLowerCase().contains(
        lowerQuery,
      );

      return nameMatch || locationMatch || specialtyMatch;
    }).toList();
  }

  /// Filtra barberías por búsqueda
  static List<WorkplaceEntity> filterWorkplacesBySearch(
    List<WorkplaceEntity> workplaces,
    String query,
  ) {
    if (query.isEmpty) {
      return workplaces;
    }

    final lowerQuery = query.toLowerCase();
    return workplaces.where((workplace) {
      final nameMatch = workplace.name.toLowerCase().contains(lowerQuery);
      final cityMatch =
          workplace.city?.toLowerCase().contains(lowerQuery) ?? false;
      final addressMatch =
          workplace.address?.toLowerCase().contains(lowerQuery) ?? false;

      return nameMatch || cityMatch || addressMatch;
    }).toList();
  }

  /// Ordena barberos según los criterios especificados
  static List<BarberEntity> sortBarbers(
    List<BarberEntity> barbers,
    String sortBy,
    String sortOrder,
  ) {
    final sorted = List<BarberEntity>.from(barbers);

    sorted.sort((a, b) {
      int comparison = 0;

      switch (sortBy) {
        case HomeConstants.sortByRating:
          comparison = a.rating.compareTo(b.rating);
          break;
        case HomeConstants.sortByReviews:
          comparison = a.reviews.compareTo(b.reviews);
          break;
        default:
          comparison = a.rating.compareTo(b.rating);
      }

      return sortOrder == HomeConstants.sortOrderDesc
          ? -comparison
          : comparison;
    });

    return sorted;
  }

  /// Ordena barberías según los criterios especificados
  static List<WorkplaceEntity> sortWorkplaces(
    List<WorkplaceEntity> workplaces,
    String sortBy,
    String sortOrder,
  ) {
    final sorted = List<WorkplaceEntity>.from(workplaces);

    sorted.sort((a, b) {
      int comparison = 0;

      switch (sortBy) {
        case HomeConstants.sortByRating:
          comparison = a.rating.compareTo(b.rating);
          break;
        case HomeConstants.sortByReviews:
          comparison = a.reviews.compareTo(b.reviews);
          break;
        default:
          comparison = a.rating.compareTo(b.rating);
      }

      return sortOrder == HomeConstants.sortOrderDesc
          ? -comparison
          : comparison;
    });

    return sorted;
  }

  /// Aplica filtros y ordenamiento a barberos
  static List<BarberEntity> applyBarberFilters(
    List<BarberEntity> barbers,
    String searchQuery,
    String sortBy,
    String sortOrder,
  ) {
    // Primero filtrar por búsqueda
    final filtered = filterBarbersBySearch(barbers, searchQuery);

    // Luego ordenar
    return sortBarbers(filtered, sortBy, sortOrder);
  }

  /// Aplica filtros y ordenamiento a barberías
  static List<WorkplaceEntity> applyWorkplaceFilters(
    List<WorkplaceEntity> workplaces,
    String searchQuery,
    String sortBy,
    String sortOrder,
  ) {
    // Primero filtrar por búsqueda
    final filtered = filterWorkplacesBySearch(workplaces, searchQuery);

    // Luego ordenar
    return sortWorkplaces(filtered, sortBy, sortOrder);
  }
}
