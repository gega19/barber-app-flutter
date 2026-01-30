import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Widget reutilizable para listas con refresh indicator e infinite scroll
class RefreshableList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function() onRefresh;
  final VoidCallback? onLoadMore;
  final EdgeInsets? padding;

  const RefreshableList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    this.onLoadMore,
    this.padding,
  });

  @override
  State<RefreshableList<T>> createState() => _RefreshableListState<T>();
}

class _RefreshableListState<T> extends State<RefreshableList<T>> {
  final ScrollController _scrollController = ScrollController();
  bool _hasTriggeredLoad = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (widget.onLoadMore == null) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    const threshold = 200.0; // Load more when 200px from bottom

    // Trigger load more once when reaching threshold
    if (maxScroll - currentScroll <= threshold) {
      if (!_hasTriggeredLoad) {
        _hasTriggeredLoad = true;
        widget.onLoadMore!();

        // Reset flag after a short delay to allow loading next page
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _hasTriggeredLoad = false;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      color: AppColors.primaryGold,
      child: ListView.builder(
        controller: _scrollController,
        padding: widget.padding ?? const EdgeInsets.all(16),
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          return widget.itemBuilder(context, widget.items[index], index);
        },
      ),
    );
  }
}
