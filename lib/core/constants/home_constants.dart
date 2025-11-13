/// Constantes para el HomeScreen
class HomeConstants {
  // Valores de ordenamiento
  static const String sortByRating = 'rating';
  static const String sortByReviews = 'reviews';

  // Valores de orden
  static const String sortOrderDesc = 'desc';
  static const String sortOrderAsc = 'asc';

  // Tiempo de debounce para búsqueda (en milisegundos)
  static const Duration searchDebounceDuration = Duration(milliseconds: 500);

  // Valores por defecto
  static const String defaultSortBy = sortByRating;
  static const String defaultSortOrder = sortOrderDesc;
}
