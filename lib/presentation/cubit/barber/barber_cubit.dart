import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/barber_entity.dart';
import '../../../domain/usecases/barber/get_barbers_usecase.dart';
import '../../../domain/usecases/barber/get_best_barbers_with_total_usecase.dart';
import '../../../domain/usecases/barber/search_barbers_usecase.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/effective_country_code_resolver.dart';
import '../../../presentation/cubit/auth/auth_cubit.dart';
import '../../../core/injection/injection.dart';
import '../../../core/utils/logger.dart';

part 'barber_state.dart';

class BarberCubit extends Cubit<BarberState> {
  final GetBarbersUseCase getBarbersUseCase;
  final GetBestBarbersWithTotalUseCase getBestBarbersWithTotalUseCase;
  final SearchBarbersUseCase searchBarbersUseCase;
  final AuthCubit authCubit;
  final EffectiveCountryCodeResolver effectiveCountryCodeResolver;
  final AnalyticsService analyticsService = sl<AnalyticsService>();

  List<BarberEntity> _allBarbers = [];
  int _currentPage = 0;
  static const int _pageSize = 10;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;
  bool _isSearchResult = false;
  int? _totalCount;

  BarberCubit({
    required this.getBarbersUseCase,
    required this.getBestBarbersWithTotalUseCase,
    required this.searchBarbersUseCase,
    required this.authCubit,
    required this.effectiveCountryCodeResolver,
  }) : super(BarberInitial());

    Future<String> _countryFilter() =>
      effectiveCountryCodeResolver.resolveForAuthStateAsync(authCubit.state);

  /// Loads barbers with pagination support
  ///
  /// [limit] - Number of items to load per page
  /// [reset] - If true, clears existing data and starts from page 0
  Future<void> loadBarbers({int limit = 10, bool reset = true}) async {
    if (isClosed) return;

    // Prevent concurrent resets (race condition fix)
    if (reset && state is BarberLoading) {
      appLogger.w(
        'BarberCubit: Ignoring duplicate load request (already loading)',
      );
      return;
    }

    if (reset) {
      appLogger.d('BarberCubit: Resetting pagination state');
      emit(BarberLoading());
      _allBarbers = [];
      _currentPage = 0;
      _hasMoreData = true;
      _isLoadingMore = false;
      _isSearchResult = false;
    }

    appLogger.d(
      'BarberCubit: Loading page $_currentPage (offset: ${_currentPage * _pageSize}, limit: $limit)',
    );
    final result = await getBestBarbersWithTotalUseCase(
      limit: limit,
      offset: _currentPage * _pageSize,
      country: await _countryFilter(),
    );

    result.fold((failure) => emit(BarberError(failure.message)), (data) {
      final barbers = data.barbers;
      _totalCount = data.total;

      appLogger.i(
        'BarberCubit: Loaded ${barbers.length} barbers (Total in DB: $_totalCount)',
      );
      _allBarbers.addAll(barbers);
      _hasMoreData = barbers.length >= limit;
      _currentPage++;

      appLogger.d(
        'BarberCubit: Current state - ${_allBarbers.length} loaded, page: $_currentPage, hasMore: $_hasMoreData',
      );
      emit(BarberLoaded(List.from(_allBarbers), totalCount: _totalCount));
    });
  }

  Future<void> searchBarbers(String query) async {
    if (query.isEmpty) {
      loadBarbers(reset: true);
      return;
    }

    _isSearchResult = true;
    emit(BarberLoading());

    // Track search
    await analyticsService.trackEvent(
      eventName: 'barber_searched',
      eventType: 'user_action',
      properties: {'query': query, 'queryLength': query.length},
    );

    final result = await searchBarbersUseCase(
      query,
      country: await _countryFilter(),
    );

    result.fold((failure) => emit(BarberError(failure.message)), (barbers) {
      emit(BarberLoaded(barbers));
      // Track search results
      analyticsService.trackEvent(
        eventName: 'barber_search_results',
        eventType: 'user_action',
        properties: {'query': query, 'resultsCount': barbers.length},
      );
    });
  }

  Future<void> loadMoreBarbers() async {
    if (_isSearchResult) {
      appLogger.d('BarberCubit: loadMore ignored - showing search results');
      return;
    }
    if (_isLoadingMore || !_hasMoreData || state is! BarberLoaded) {
      appLogger.d(
        'BarberCubit: loadMore ignored - loading: $_isLoadingMore, hasMore: $_hasMoreData',
      );
      return;
    }

    appLogger.d(
      'BarberCubit: Loading more - page $_currentPage (offset: ${_currentPage * _pageSize})',
    );
    _isLoadingMore = true;

    final result = await getBestBarbersWithTotalUseCase(
      limit: _pageSize,
      offset: _currentPage * _pageSize,
      country: await _countryFilter(),
    );

    result.fold(
      (failure) {
        appLogger.w('BarberCubit: Load more failed - ${failure.message}');
        _isLoadingMore = false;
      },
      (data) {
        final barbers = data.barbers;
        appLogger.i(
          'BarberCubit: Loaded ${barbers.length} more barbers (Total loaded: ${_allBarbers.length + barbers.length})',
        );

        _allBarbers.addAll(barbers);

        _hasMoreData = barbers.length >= _pageSize;
        _currentPage++;
        _isLoadingMore = false;
        emit(BarberLoaded(List.from(_allBarbers), totalCount: _totalCount));
      },
    );
  }

  Future<BarberEntity?> fetchBarberById(String id) async {
    try {
      final cached = _allBarbers.firstWhere((b) => b.id == id);
      return cached;
    } catch (_) {}

    final result = await getBarbersUseCase.repository.getBarberById(id);

    return result.fold(
      (failure) {
        appLogger.e(
          'BarberCubit: Failed to fetch barber $id - ${failure.message}',
        );
        return null;
      },
      (barber) {
        return barber;
      },
    );
  }

  void clearSearch() {
    loadBarbers(reset: true);
  }
}
