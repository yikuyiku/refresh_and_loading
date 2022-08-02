part of refresh_and_loading;

class RefreshIndicatorStatusData {
  const RefreshIndicatorStatusData(this.indicatorStatus, {this.offset});

  final RefreshIndicatorStatus indicatorStatus;
  final double? offset;
}

class LoadingIndicatorStatusData {
  const LoadingIndicatorStatusData(this.indicatorStatus, {this.offset});

  final LoadMoreIndicatorStatus indicatorStatus;
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
}
enum RefreshIndicatorStatus {
  drag, // 拖动中
  arrived, // 到达
  snap, // 消失
  refresh, // 刷新
  done, // 完成
  canceled, // 取消拖动
  error, // 错误
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
  const RefreshAndLoadMore(
      {Key? key,
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
      required this.child,
      required this.refreshLoadingController})
      : super(key: key);
  final bool reverse;
  final double maxRefreshDragOffset;
  final double maxLoadingDragOffset;
  final Future Function()? onRefresh;
  final void Function()? onLoadingMore;
  final Widget child;
  final RefreshLoadingController refreshLoadingController;

  final bool? primary;
  final double? cacheExtent;

  final Axis? scrollDirection;
  final int? semanticChildCount;
  final ScrollController? scrollController;
  final DragStartBehavior? dragStartBehavior;
  final ScrollPhysics? physics;

  @override
  State<RefreshAndLoadMore> createState() => RefreshAndLoadMoreState();
}

class RefreshAndLoadMoreState extends State<RefreshAndLoadMore> {
  Stream<RefreshIndicatorStatusData> get refreshStream => _refreshStream.stream;

  Stream<LoadingIndicatorStatusData> get loadMoreStream =>
      _loadMoreStream.stream;
  late final StreamController<RefreshIndicatorStatusData> _refreshStream;
  late final StreamController<LoadingIndicatorStatusData> _loadMoreStream;

  RefreshIndicatorStatus _refreshStatus = RefreshIndicatorStatus.done;
  LoadMoreIndicatorStatus _loadMoreStatus = LoadMoreIndicatorStatus.done;

  double _refreshDragOffsetValue = 0;

  double get _refreshDragOffset => _refreshDragOffsetValue;

  set _refreshDragOffset(double value) {
    value = math.max(0.0, math.min(value, 300));
    _refreshDragOffsetValue = value;
    _notificationRefreshIndicator();
  }

  double _loadMoreDragOffsetValue = 0;

  double get _loadMoreDragOffset => _loadMoreDragOffsetValue;

  set _loadMoreDragOffset(double value) {
    value = math.max(0.0, math.min(value, 300));
    _loadMoreDragOffsetValue = value;
    _notificationLoadMoreIndicator();
  }

  ScrollController? refreshScrollController;

  @override
  void initState() {
    super.initState();
    if (widget.scrollController == null) {
      refreshScrollController = ScrollController();
    }
    if (widget.onRefresh != null) {
      _refreshStream = StreamController<RefreshIndicatorStatusData>.broadcast();
    }
    if (widget.onLoadingMore != null) {
      _loadMoreStream =
          StreamController<LoadingIndicatorStatusData>.broadcast();
    }
    widget.refreshLoadingController.headerMode?.addListener(() {
      RefreshIndicatorStatus? refreshIndicatorStatus =
          widget.refreshLoadingController.headerMode!.value;
      switch (refreshIndicatorStatus) {
        case RefreshIndicatorStatus.done:
          _refreshStatus = refreshIndicatorStatus;
          _refreshDragOffset = 0;
          widget.refreshLoadingController.headerMode?.value =
              RefreshIndicatorStatus.snap;
          break;
      }
    });
    widget.refreshLoadingController.footerMode?.addListener(() {
      LoadMoreIndicatorStatus? loadMoreIndicatorStatus =
          widget.refreshLoadingController.footerMode!.value;
      switch (loadMoreIndicatorStatus) {
        case LoadMoreIndicatorStatus.done:
          _loadMoreStatus = loadMoreIndicatorStatus;
          _loadMoreDragOffset = 0;
          widget.refreshLoadingController.footerMode?.value =
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
        //avoid system inject padding when own indicator top or bottom
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
    if (widget.onRefresh != null) {
      slivers?.insert(0, const SliverToBoxAdapter(child: ARefreshIndicator()));
    }
    if (widget.onLoadingMore != null) {
      slivers?.add(const SliverToBoxAdapter(child: LoadingIndicator()));
    }

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
        primary = primary ?? childView.primary;
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
                0, const SliverToBoxAdapter(child: ARefreshIndicator()));
          }
          if (widget.onLoadingMore != null) {
            slivers?.add(const SliverToBoxAdapter(child: LoadingIndicator()));
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
    return NotificationListener(
      onNotification: _notifiListener,
      child: body!,
    );
  }

  _checkLoadMore(double overscroll) {
    double step = overscroll /
        ((_loadMoreDragOffset > widget.maxLoadingDragOffset) ? 3 : 1);
    _loadMoreDragOffset = _loadMoreDragOffset + (widget.reverse ? -step : step);
    if (_loadMoreDragOffset > widget.maxLoadingDragOffset/2 &&
        _loadMoreStatus != LoadMoreIndicatorStatus.loading) {
      // print("load more arrived");
      _loadMoreStatus = LoadMoreIndicatorStatus.arrived;
    }
  }

  _checkRefresh(double overscroll) {
    double step = overscroll /
        ((_refreshDragOffset > widget.maxRefreshDragOffset) ? 3 : 2);
    _refreshDragOffset = _refreshDragOffset + (widget.reverse ? step : -step);
    if (_refreshDragOffset > widget.maxRefreshDragOffset &&
        _refreshStatus != RefreshIndicatorStatus.refresh) {
      _refreshStatus = RefreshIndicatorStatus.arrived;
    }
  }

  bool _notifiListener(ScrollNotification notification) {
    switch (notification.runtimeType) {
      case ScrollStartNotification:
        break;
      case ScrollUpdateNotification:
        notification as ScrollUpdateNotification;
        if (notification.scrollDelta != null && notification.scrollDelta! < 0) {
          _checkRefresh(notification.scrollDelta ?? 0);
        }
        if (notification.metrics.extentAfter > 0.0) {
          if (widget.reverse && widget.onLoadingMore != null) {
            _checkLoadMore(notification.scrollDelta ?? 0);
          } else if (widget.onRefresh != null) {
            _checkRefresh(notification.scrollDelta ?? 0);
          }
        } else if (notification.metrics.extentBefore > 0.0) {
          if (widget.reverse && widget.onRefresh != null) {
            _checkRefresh(notification.scrollDelta ?? 0);
          } else if (widget.onLoadingMore != null) {
            _checkLoadMore(notification.scrollDelta ?? 0);
          }
        }
        break;
      case OverscrollNotification:
        notification as OverscrollNotification;
        if (notification.metrics.extentAfter > 0.0) {
          if (widget.reverse && widget.onLoadingMore != null) {
            _checkLoadMore(notification.overscroll);
          } else if (widget.onRefresh != null) {
            _checkRefresh(notification.overscroll);
          }
        } else if (notification.metrics.extentBefore > 0.0) {
          if (widget.reverse && widget.onRefresh != null) {
            _checkRefresh(notification.overscroll);
          } else if (widget.onLoadingMore != null) {
            _checkLoadMore(notification.overscroll);
          }
        }
        break;
      case ScrollEndNotification:
        if (_refreshDragOffset > widget.maxRefreshDragOffset &&
            _refreshStatus == RefreshIndicatorStatus.arrived) {
          _refreshDragOffset = widget.maxRefreshDragOffset;
          _notificationRefreshIndicator();
          _doRefresh();
        } else if (_refreshStatus != RefreshIndicatorStatus.refresh) {
          _putAwayRefresh();
        } else if (_refreshStatus == RefreshIndicatorStatus.refresh) {
          _refreshDragOffset = widget.maxRefreshDragOffset;
        }
        if (_loadMoreDragOffset > widget.maxLoadingDragOffset &&
            _loadMoreStatus == LoadMoreIndicatorStatus.arrived) {
          _loadMoreDragOffset = widget.maxLoadingDragOffset;
          _notificationRefreshIndicator();
          _doLoadMore();
        } else if (_loadMoreStatus != LoadMoreIndicatorStatus.loading) {
          _putAwayLoadMore();
        } else if (_loadMoreStatus == LoadMoreIndicatorStatus.loading) {
          _loadMoreDragOffset = widget.maxLoadingDragOffset;
        }
        break;
    }

    return false;
  }

  Future _doRefresh() async {
    _refreshStatus = RefreshIndicatorStatus.refresh;
    _notificationRefreshIndicator();

    widget.onRefresh?.call();
  }

  _doLoadMore(
      {Duration duration = const Duration(milliseconds: 300),
      Curve curve = Curves.linear}) async {
    _loadMoreStatus = LoadMoreIndicatorStatus.loading;
    _loadMoreDragOffset = widget.maxLoadingDragOffset;
    ScrollController? scrollController =
        widget.scrollController ?? refreshScrollController;
    scrollController?.jumpTo(scrollController.position.maxScrollExtent +
        widget.maxLoadingDragOffset);
    widget.onLoadingMore?.call();
  }

  _putAwayRefresh() {
    _refreshStatus = RefreshIndicatorStatus.canceled;
    _refreshDragOffset = 0;
  }

  _putAwayLoadMore() {
    _loadMoreStatus = LoadMoreIndicatorStatus.canceled;
    _loadMoreDragOffset = 0;
  }

  void _notificationRefreshIndicator() {
    _refreshStream.add(
        RefreshIndicatorStatusData(_refreshStatus, offset: _refreshDragOffset));
  }

  void _notificationLoadMoreIndicator() {
    _loadMoreStream.add(LoadingIndicatorStatusData(_loadMoreStatus,
        offset: _loadMoreDragOffset));
  }
}
