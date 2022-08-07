part of refresh_and_loading;

class RefreshIndicatorStatusData {
  const RefreshIndicatorStatusData(this.indicatorStatus, {this.offset});

  final RefreshIndicatorStatus indicatorStatus;
  final double? offset;
}

class LoadingIndicatorStatusData {
  const LoadingIndicatorStatusData({this.offset});

  final double? offset;
}

enum LoadMoreIndicatorStatus {
  drag, // 拖动中
  arrived, // 到达
  snap, // 消失
  loading, // 刷新
  done, // 完成
  canceled, // 取消拖动
  error, // 错误
  withoutNextPage
}
enum RefreshIndicatorStatus {
  drag, // 拖动中
  arrived, // 到达
  snap, // 消失
  refresh, // 刷新
  done, // 完成
  canceled, // 取消拖动
  error, // 错误
  empty
}

class RefreshAndLoadingEvent {
  const RefreshAndLoadingEvent(
      {this.loadMoreIndicatorStatus, this.refreshIndicatorStatus});

  final RefreshIndicatorStatus? refreshIndicatorStatus;
  final LoadMoreIndicatorStatus? loadMoreIndicatorStatus;
}

///指示器类型
enum IndicatorType { refresh, loadMore }

class RefreshAndLoadMore extends StatefulWidget {
  const RefreshAndLoadMore({
    Key? key,
    this.reverse = false,
    this.maxRefreshDragOffset = 80.0,
    this.maxLoadingDragOffset = 60.0,
    this.onRefresh,
    this.onLoadingMore,
    this.primary = false,
    this.cacheExtent,
    this.scrollDirection,
    this.semanticChildCount,
    this.scrollController,
    this.dragStartBehavior,
    this.physics,
    this.refreshLoadingController,
    this.headerIndicator,
    this.footerIndicator,
    Widget? emptyWidget,
    required this.child,
  })  : emptyWidget = emptyWidget ?? const SizedBox(),
        super(key: key);
  final bool reverse;
  final double maxRefreshDragOffset;
  final double maxLoadingDragOffset;
  final Future Function()? onRefresh;
  final void Function()? onLoadingMore;
  final Widget child;
  final RefreshLoadingController? refreshLoadingController;

  final bool? primary;
  final double? cacheExtent;

  final Axis? scrollDirection;
  final int? semanticChildCount;
  final ScrollController? scrollController;
  final DragStartBehavior? dragStartBehavior;
  final ScrollPhysics? physics;
  final Widget? headerIndicator;
  final Widget? footerIndicator;
  final Widget emptyWidget;

  @override
  State<RefreshAndLoadMore> createState() => RefreshAndLoadMoreState();
}

class RefreshAndLoadMoreState extends State<RefreshAndLoadMore> {
  double _refreshDragOffsetValue = 0;

  double get _refreshDragOffset => _refreshDragOffsetValue;

  set _refreshDragOffset(double value) {
    value = math.max(0.0, math.min(value, widget.maxRefreshDragOffset * 2));
    _refreshDragOffsetValue = value;
    _notificationRefreshIndicator();
  }

  double _loadMoreDragOffsetValue = 0;

  double get _loadMoreDragOffset => _loadMoreDragOffsetValue;

  set _loadMoreDragOffset(double value) {
    value = math.max( widget.maxLoadingDragOffset, math.min(value, widget.maxLoadingDragOffset * 2));
    _loadMoreDragOffsetValue = value;
    _notificationLoadMoreIndicator();
  }

  ScrollController? refreshScrollController;

  @override
  void didUpdateWidget(covariant RefreshAndLoadMore oldWidget) {
    // widget.refreshLoadingController = oldWidget.refreshLoadingController;
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    if (widget.scrollController == null) {
      refreshScrollController = ScrollController();
    }

    widget.refreshLoadingController?.headerMode?.addListener(() {
      RefreshIndicatorStatus? refreshIndicatorStatus =
          widget.refreshLoadingController?.headerMode!.value;
      switch (refreshIndicatorStatus) {
        case RefreshIndicatorStatus.done:
          widget.refreshLoadingController?.headerMode?.value =
              refreshIndicatorStatus!;
          _refreshDragOffset = 0;
          widget.refreshLoadingController?.headerMode?.value =
              RefreshIndicatorStatus.snap;
          break;
      }
    });
    widget.refreshLoadingController?.footerMode?.addListener(() {
      LoadMoreIndicatorStatus? loadMoreIndicatorStatus =
          widget.refreshLoadingController?.footerMode!.value;
      switch (loadMoreIndicatorStatus) {
        case LoadMoreIndicatorStatus.done:
          _loadMoreDragOffset = 0;
          widget.refreshLoadingController?.footerMode?.value =
              LoadMoreIndicatorStatus.snap;

          break;
      }
    });
  }

  List<Widget>? _buildSliversByChild(
    BuildContext context,
    Widget? child,
  ) {
    List<Widget>? slivers;
    if (child is ScrollView) {
      if (child is BoxScrollView) {
        Widget sliver = child.buildChildLayout(context);
        if (child.padding != null) {
          slivers = [SliverPadding(sliver: sliver, padding: child.padding!)];
        } else {
          slivers = [sliver];
        }
      } else {
        slivers = List.from(child.buildSlivers(context), growable: true);
      }
    } else if (child is! Scrollable) {
      slivers = [
        SliverRefreshBody(
          child: child ?? Container(),
        )
      ];
    }
    slivers?.insert(0, SliverToBoxAdapter(child: widget.headerIndicator));
    slivers?.add(SliverToBoxAdapter(child: widget.footerIndicator));

    return slivers;
  }

  Widget? _buildBodyBySlivers(
    Widget? childView,
    List<Widget>? slivers,
  ) {
    Widget? body;
    if (childView is! Scrollable) {
      bool? primary = widget.primary;
      Key? key;
      double? cacheExtent = widget.cacheExtent;

      Axis? scrollDirection = widget.scrollDirection;
      int? semanticChildCount = widget.semanticChildCount;
      bool? reverse = widget.reverse;
      ScrollController? scrollController =
          widget.scrollController ?? refreshScrollController;
      DragStartBehavior? dragStartBehavior = widget.dragStartBehavior;
      ScrollPhysics? physics =
          widget.physics ?? const AlwaysScrollableScrollPhysics();
      // ScrollPhysics? physics =
      //     widget.physics ?? const AlwaysScrollableScrollPhysics();
      Key? center;
      double? anchor;
      ScrollViewKeyboardDismissBehavior? keyboardDismissBehavior;
      String? restorationId;
      Clip? clipBehavior;

      if (childView is ScrollView) {
        primary = primary;
        cacheExtent = cacheExtent ?? childView.cacheExtent;
        key = key ?? childView.key;
        semanticChildCount = semanticChildCount ?? childView.semanticChildCount;
        reverse = reverse;
        dragStartBehavior = dragStartBehavior ?? childView.dragStartBehavior;
        scrollDirection = scrollDirection ?? childView.scrollDirection;
        physics = physics;
        center = center ?? childView.center;
        anchor = anchor ?? childView.anchor;
        keyboardDismissBehavior =
            keyboardDismissBehavior ?? childView.keyboardDismissBehavior;
        restorationId = restorationId ?? childView.restorationId;
        clipBehavior = clipBehavior ?? childView.clipBehavior;
        scrollController = scrollController ?? childView.controller;
      }
      body = CustomScrollView(
        // ignore: DEPRECATED_MEMBER_USE_FROM_SAME_PACKAGE
        controller: scrollController,
        cacheExtent: cacheExtent,
        key: key,
        scrollDirection: scrollDirection ?? Axis.vertical,
        semanticChildCount: semanticChildCount,
        primary: primary,
        clipBehavior: clipBehavior ?? Clip.hardEdge,
        keyboardDismissBehavior:
            keyboardDismissBehavior ?? ScrollViewKeyboardDismissBehavior.manual,
        anchor: anchor ?? 0.0,
        restorationId: restorationId,
        center: center,
        physics: physics,
        slivers: slivers!,
        dragStartBehavior: dragStartBehavior ?? DragStartBehavior.start,
        reverse: reverse,
      );
    } else if (childView is Scrollable) {
      body = Scrollable(
        physics: widget.physics,
        controller: childView.controller,
        axisDirection: childView.axisDirection,
        semanticChildCount: childView.semanticChildCount,
        dragStartBehavior: childView.dragStartBehavior,
        viewportBuilder: (context, offset) {
          Viewport viewport =
              childView.viewportBuilder(context, offset) as Viewport;
          if (widget.onRefresh != null) {
            slivers?.insert(
                0, SliverToBoxAdapter(child: widget.headerIndicator));
          }
          if (widget.onLoadingMore != null) {
            slivers?.add(SliverToBoxAdapter(child: widget.footerIndicator));
          }
          return viewport;
        },
      );
    }
    return body;
  }

  @override
  Widget build(BuildContext context) {
    Widget? body;

    List<Widget>? slivers = _buildSliversByChild(
      context,
      widget.child,
    );
    body = _buildBodyBySlivers(widget.child, slivers);
    return ValueListenableBuilder(
        valueListenable: widget.refreshLoadingController!.headerMode!,
        builder: (context, data, child) {
          return NotificationListener(
            onNotification: _notifiListener,
            child: data == RefreshIndicatorStatus.empty
                ? widget.emptyWidget
                : body!,
          );
        });
  }

  _checkLoadMore(double? overscroll) {
    if (overscroll != null &&
        widget.refreshLoadingController?.footerMode?.value !=
            LoadMoreIndicatorStatus.withoutNextPage &&
        widget.refreshLoadingController?.footerMode?.value !=
            LoadMoreIndicatorStatus.loading) {
      double step = overscroll /
          ((_loadMoreDragOffset > widget.maxLoadingDragOffset) ? 3 : 0.5);
      _loadMoreDragOffset = _loadMoreDragOffset + step;
      if (_loadMoreDragOffset > widget.maxLoadingDragOffset  &&
          widget.refreshLoadingController?.footerMode?.value !=
              LoadMoreIndicatorStatus.loading) {
        widget.refreshLoadingController?.footerMode?.value =
            LoadMoreIndicatorStatus.arrived;
      }
    }
  }

  _checkRefresh(double? overscroll) {
    if (overscroll != null) {
      double step = overscroll /
          ((_refreshDragOffset > widget.maxRefreshDragOffset) ? 3 : 2);
      _refreshDragOffset = _refreshDragOffset - step;
      if (_refreshDragOffset > widget.maxRefreshDragOffset &&
          widget.refreshLoadingController?.headerMode?.value !=
              RefreshIndicatorStatus.refresh) {
        widget.refreshLoadingController?.headerMode?.value =
            RefreshIndicatorStatus.arrived;
      }
    }
  }

  bool _notifiListener(ScrollNotification notification) {
    switch (notification.runtimeType) {
      case ScrollStartNotification:
        break;
      case ScrollUpdateNotification:
        notification as ScrollUpdateNotification;

        // if (notification.metrics.extentBefore == 0.0 &&
        //     notification.metrics.pixels == 0) {
        //   if (widget.reverse && widget.onLoadingMore != null) {
        //     _checkRefresh(notification.scrollDelta ?? 0);
        //   } else if (!widget.reverse && widget.onRefresh != null) {
        //     _checkLoadMore(notification.scrollDelta ?? 0);
        //   }
        // }
        // if (notification.metrics.extentAfter == 0.0) {
        //   if (widget.reverse && widget.onRefresh != null) {
        //     _checkLoadMore(notification.scrollDelta ?? 0);
        //   } else if (!widget.reverse && widget.onLoadingMore != null) {
        //     _checkRefresh(notification.scrollDelta ?? 0);
        //   }
        // }

        if (widget.reverse) {
          if (notification.metrics.extentAfter == 0.0) {
            _checkLoadMore(notification.scrollDelta);
          }
          if (notification.metrics.extentBefore == 0.0) {
            _checkRefresh(notification.scrollDelta);
          }
        } else {
          if (notification.metrics.extentBefore == 0.0) {
            _checkRefresh(notification.scrollDelta);
          }
          if (notification.metrics.extentAfter == 0.0) {
            _checkLoadMore(notification.scrollDelta);
          }
        }
        break;
      case OverscrollNotification:
        notification as OverscrollNotification;
        // if (kDebugMode) {
        //   print(
        //       "-----------------------------------------------------------------");
        //
        //   print("extentAfter: ${notification.metrics.extentAfter}");
        //   print("extentBefore: ${notification.metrics.extentBefore}");
        //   print("overscroll: ${notification.overscroll}");
        //   print("pixels: ${notification.metrics.pixels}");
        //   print("pixels: ${notification.metrics.axisDirection}");
        //   print(
        //       "-----------------------------------------------------------------");
        // }
        if (widget.reverse) {
          if (notification.metrics.extentAfter == 0.0) {
            _checkLoadMore(notification.overscroll);
          }
          if (notification.metrics.extentBefore == 0.0) {
            _checkRefresh(notification.overscroll);
          }
        } else {
          if (notification.metrics.extentBefore == 0.0) {
            _checkRefresh(notification.overscroll);
          }
          if (notification.metrics.extentAfter == 0.0) {
            _checkLoadMore(notification.overscroll);
          }
        }
        break;
      case ScrollEndNotification:
        if (_refreshDragOffset > widget.maxRefreshDragOffset &&
            widget.refreshLoadingController?.headerMode?.value ==
                RefreshIndicatorStatus.arrived) {
          _refreshDragOffset = widget.maxRefreshDragOffset;
          _notificationRefreshIndicator();
          _doRefresh();
        } else if (widget.refreshLoadingController?.headerMode?.value !=
            RefreshIndicatorStatus.refresh) {
          _putAwayRefresh();
        } else if (widget.refreshLoadingController?.headerMode?.value ==
            RefreshIndicatorStatus.refresh) {
          _refreshDragOffset = widget.maxRefreshDragOffset;
        }
        if (_loadMoreDragOffset > widget.maxLoadingDragOffset &&
            widget.refreshLoadingController?.footerMode?.value ==
                LoadMoreIndicatorStatus.arrived &&
            widget.refreshLoadingController?.footerMode?.value !=
                LoadMoreIndicatorStatus.loading) {
          widget.refreshLoadingController?.footerMode?.value =
              LoadMoreIndicatorStatus.loading;
          _loadMoreDragOffset = widget.maxLoadingDragOffset;
          // _notificationRefreshIndicator();
          _doLoadMore();
        } else if (widget.refreshLoadingController?.footerMode?.value !=
                LoadMoreIndicatorStatus.withoutNextPage &&
            widget.refreshLoadingController?.footerMode?.value !=
                LoadMoreIndicatorStatus.loading) {
          _putAwayLoadMore();
        }
        break;
    }

    return false;
  }

  Future _doRefresh() async {
    widget.refreshLoadingController?.headerMode?.value =
        RefreshIndicatorStatus.refresh;
    _notificationRefreshIndicator();

    widget.onRefresh?.call();
  }

  _doLoadMore() async {
    if (widget.refreshLoadingController?.footerMode?.value !=
        LoadMoreIndicatorStatus.withoutNextPage) {
      _loadMoreDragOffset = widget.maxLoadingDragOffset;
      // ScrollController? scrollController =
      //     widget.scrollController ?? refreshScrollController;
      // scrollController?.jumpTo(scrollController.position.maxScrollExtent +
      //     widget.maxLoadingDragOffset);
      widget.onLoadingMore?.call();
    }
  }

  _putAwayRefresh() {
    widget.refreshLoadingController?.headerMode?.value =
        RefreshIndicatorStatus.canceled;
    _refreshDragOffset = 0;
  }

  _putAwayLoadMore() {
    widget.refreshLoadingController?.footerMode?.value =
        LoadMoreIndicatorStatus.canceled;
    _loadMoreDragOffset = 0;
  }

  void _notificationRefreshIndicator() {
    widget.refreshLoadingController?.refreshDragOffset?.value =
        _refreshDragOffset;
  }

  void _notificationLoadMoreIndicator() {
    widget.refreshLoadingController?.loadMoreDragOffset?.value =
        _loadMoreDragOffset;
  }
}
