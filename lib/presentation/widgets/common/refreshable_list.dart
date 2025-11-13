import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Widget reutilizable para listas con refresh indicator
class RefreshableList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function() onRefresh;
  final EdgeInsets? padding;

  const RefreshableList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primaryGold,
      child: ListView.builder(
        padding: padding ?? const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return itemBuilder(context, items[index], index);
        },
      ),
    );
  }
}
