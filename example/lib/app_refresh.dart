import 'package:flutter/material.dart';
import 'package:refresh_and_loading/refresh_and_loading.dart';

class AppRefresh<T> extends StatelessWidget {
  final bool? reverse;
  final double? maxDragOffset;
  final Future Function()? onRefresh;
  final void Function()? onLoadingMore;
  final Widget child;
  final Stream<RefreshAndLoadingEvent> refreshAndLoadMoreStream;

  const AppRefresh(
      {Key? key,
        this.reverse,
        this.maxDragOffset,
        this.onRefresh,
        this.onLoadingMore,
        required this.child,
        required this.refreshAndLoadMoreStream})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshAndLoadMore(
        onRefresh: onRefresh,
        onLoadingMore: onLoadingMore,
        refreshAndLoadMoreStream: refreshAndLoadMoreStream,
        maxRefreshDragOffset: 80,
        maxLoadingDragOffset: 80,
        child: CustomScrollView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: ARefreshIndicator()),
            SliverToBoxAdapter(child: child),
            const SliverToBoxAdapter(child: LoadingIndicator()),
          ],
        ));
  }
}
