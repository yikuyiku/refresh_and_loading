import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:refresh_and_loading/refresh_and_loading.dart';

class AppRefresh<T> extends StatelessWidget {
  final bool? reverse;
  final double? maxDragOffset;
  final Future Function()? onRefresh;
  final void Function()? onLoadingMore;
  final Widget child;
  final RefreshLoadingController controller;

  final bool? primary;
  final double? cacheExtent;

  final Axis? scrollDirection;
  final int? semanticChildCount;
  final ScrollController? scrollController;
  final DragStartBehavior? dragStartBehavior;
  final ScrollPhysics? physics;

  const AppRefresh(
      {Key? key,
      this.reverse,
      this.maxDragOffset,
      this.onRefresh,
      this.onLoadingMore,
      this.primary,
      this.cacheExtent,
      this.scrollDirection,
      this.semanticChildCount,
      this.scrollController,
      this.dragStartBehavior,
      this.physics,
      required this.child,
      required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshAndLoadMore(
        // reverse: true,
        refreshLoadingController: controller,
        onRefresh: onRefresh,
        onLoadingMore: onLoadingMore,
        maxRefreshDragOffset: 100,
        maxLoadingDragOffset: 60,
        // primary: primary,
        cacheExtent: cacheExtent,
        scrollDirection: scrollDirection,
        semanticChildCount: semanticChildCount,
        scrollController: scrollController,
        dragStartBehavior: dragStartBehavior,
        physics: physics,
        child: child,
        footerIndicator: LoadingIndicator(
          endOfListWidget: Container(
            height: 50,
            alignment: Alignment.center,
            child: const Text("That is the end of the list"),
          ),
        ),
        headerIndicator: const ARefreshIndicator(),
        emptyWidget: const Center(
          child: Text("Empty Data"),
        ));
  }
}
