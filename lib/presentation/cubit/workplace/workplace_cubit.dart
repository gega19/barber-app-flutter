import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/workplace_entity.dart';
import '../../../domain/usecases/workplace/get_best_workplaces_with_total_usecase.dart';
import '../../../domain/usecases/workplace/search_workplaces_usecase.dart';

part 'workplace_state.dart';

class WorkplaceCubit extends Cubit<WorkplaceState> {
  final GetBestWorkplacesWithTotalUseCase getBestWorkplacesWithTotalUseCase;
  final SearchWorkplacesUseCase searchWorkplacesUseCase;

  List<WorkplaceEntity> _allWorkplaces = [];
  int _currentPage = 0;
  static const int _pageSize = 10;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;
  bool _isSearchResult = false;
  int? _totalCount;

  WorkplaceCubit({
    required this.getBestWorkplacesWithTotalUseCase,
    required this.searchWorkplacesUseCase,
  }) : super(WorkplaceInitial());

  Future<void> loadWorkplaces({int limit = 10, bool reset = true}) async {
    if (isClosed) return;

    if (reset && state is WorkplaceLoading) return;

    if (reset) {
      emit(WorkplaceLoading());
      _allWorkplaces = [];
      _currentPage = 0;
      _hasMoreData = true;
      _isLoadingMore = false;
      _isSearchResult = false;
    }

    final result = await getBestWorkplacesWithTotalUseCase(
      limit: limit,
      offset: _currentPage * _pageSize,
    );

    result.fold((failure) => emit(WorkplaceError(failure.message)), (data) {
      final workplaces = data.workplaces;
      _totalCount = data.total;
      _allWorkplaces.addAll(workplaces);
      _hasMoreData = workplaces.length >= limit;
      _currentPage++;
      emit(WorkplaceLoaded(List.from(_allWorkplaces), totalCount: _totalCount));
    });
  }

  Future<void> searchWorkplaces(String query) async {
    if (isClosed) return;

    if (query.isEmpty) {
      loadWorkplaces(reset: true);
      return;
    }

    _isSearchResult = true;
    emit(WorkplaceLoading());

    final result = await searchWorkplacesUseCase(query);

    result.fold(
      (failure) => emit(WorkplaceError(failure.message)),
      (workplaces) => emit(WorkplaceLoaded(workplaces)),
    );
  }

  Future<void> loadMoreWorkplaces() async {
    if (isClosed) return;
    if (_isSearchResult) return;
    if (_isLoadingMore || !_hasMoreData || state is! WorkplaceLoaded) return;

    _isLoadingMore = true;

    final result = await getBestWorkplacesWithTotalUseCase(
      limit: _pageSize,
      offset: _currentPage * _pageSize,
    );

    result.fold(
      (failure) {
        _isLoadingMore = false;
      },
      (data) {
        final workplaces = data.workplaces;
        _allWorkplaces.addAll(workplaces);
        _hasMoreData = workplaces.length >= _pageSize;
        _currentPage++;
        _isLoadingMore = false;
        emit(
          WorkplaceLoaded(List.from(_allWorkplaces), totalCount: _totalCount),
        );
      },
    );
  }

  void clearSearch() {
    loadWorkplaces(reset: true);
  }
}
