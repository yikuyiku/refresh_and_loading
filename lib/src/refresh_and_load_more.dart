part of refresh_and_loading;

class IndicatorStatusData {
  const IndicatorStatusData(this.pullIndicatorMode, {this.offset});

  final RefreshIndicatorStatus pullIndicatorMode;
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
  const RefreshAndLoadMore({
    Key? key,
    this.reverse = false,
    this.maxDragOffset = 80.0,
    this.onRefresh,
    this.onLoadingMore,
    required this.child,
    required this.refreshAndLoadMoreStream,
  }) : super(key: key);
  final bool reverse;
  final double maxDragOffset;
  final Future Function()? onRefresh;
  final void Function()? onLoadingMore;
  final Widget child;
  final Stream<RefreshAndLoadingEvent> refreshAndLoadMoreStream;

  @override
  State<RefreshAndLoadMore> createState() => _RefreshAndLoadMoreState();
}

class _RefreshAndLoadMoreState extends State<RefreshAndLoadMore> {
  late final StreamController<IndicatorStatusData> _refreshStream;
  late final StreamController<IndicatorStatusData> _loadMoreStream;

  RefreshIndicatorStatus _refreshStatus = RefreshIndicatorStatus.done;
  LoadMoreIndicatorStatus _loadMoreStatus = LoadMoreIndicatorStatus.done;

  double _refreshDragOffsetValue = 0;

  double get _refreshDragOffset => _refreshDragOffsetValue;

  set _refreshDragOffset(double value) {
    value = math.max(0.0, math.min(value, widget.maxDragOffset * 3));
    _refreshDragOffsetValue = value;
    _notificationRefreshIndicator();
  }

  double _loadMoreDragOffsetValue = 0;

  double get _loadMoreDragOffset => _loadMoreDragOffsetValue;

  set _loadMoreDragOffset(double value) {
    value = math.max(0.0, math.min(value, widget.maxDragOffset * 3));
    _loadMoreDragOffsetValue = value;
    _notificationLoadMoreIndicator();
  }

  @override
  void initState() {
    super.initState();
    if (widget.onRefresh != null) {
      _refreshStream = StreamController<IndicatorStatusData>.broadcast();
    }
    if (widget.onLoadingMore != null) {
      _loadMoreStream = StreamController<IndicatorStatusData>.broadcast();
    }
    widget.refreshAndLoadMoreStream.listen((event) {
      if (event.refreshIndicatorStatus != null) {
        _refreshStatus = event.refreshIndicatorStatus!;
        _refreshDragOffset = 0;
      } else if (event.loadMoreIndicatorStatus != null) {
        _loadMoreStatus = event.loadMoreIndicatorStatus!;
        _loadMoreDragOffset = 0;
      }
    });
  }

  _buildRefresh() {
    return SliverToBoxAdapter(
      child: StreamBuilder<IndicatorStatusData>(
          stream: _refreshStream.stream,
          builder: (context, AsyncSnapshot<IndicatorStatusData> snapshot) {
            double offset = snapshot.data?.offset ?? 0;
            double progress = offset / widget.maxDragOffset;
            progress = progress > 1 ? 1 : progress;
            // progress = progress == 0 ? 1 : progress;
            return Container(
              height: offset,
              alignment: Alignment.topCenter,
              padding: EdgeInsets.only(top: widget.maxDragOffset / 2 - 15),
              child: (_refreshStatus == RefreshIndicatorStatus.arrived ||
                  _refreshStatus == RefreshIndicatorStatus.refresh)
                  ? const CupertinoActivityIndicator(radius: 15)
                  : CupertinoActivityIndicator.partiallyRevealed(
                progress: progress,
                radius: 15,
              ),
              // child: const PullActivityIndicator(),
            );
          }),
    );
  }

  _buildLoadMore() {
    return SliverToBoxAdapter(
      child: StreamBuilder<IndicatorStatusData>(
          stream: _loadMoreStream.stream,
          builder: (context, AsyncSnapshot<IndicatorStatusData> snapshot) {
            double offset = snapshot.data?.offset ?? 0;
            double progress = offset / widget.maxDragOffset;
            progress = progress > 1 ? 1 : progress;
            progress = progress == 0 ? 1 : progress;
            return Container(
              height: offset,
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.only(bottom: 30),
              child: (_loadMoreStatus == LoadMoreIndicatorStatus.arrived ||
                  _loadMoreStatus == LoadMoreIndicatorStatus.loading)
                  ? const CupertinoActivityIndicator(radius: 15)
                  : CupertinoActivityIndicator.partiallyRevealed(
                progress: progress,
                radius: 15,
              ),
              // child: const PullActivityIndicator(),
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: _notifiListener,
      child: CustomScrollView(slivers: [
        if (widget.reverse && widget.onLoadingMore != null) _buildLoadMore(),
        if (!widget.reverse && widget.onRefresh != null) _buildRefresh(),
        SliverToBoxAdapter(
          child: widget.child,
        ),
        if (widget.reverse && widget.onRefresh != null) _buildRefresh(),
        if (!widget.reverse && widget.onLoadingMore != null) _buildLoadMore(),
      ]),
    );
  }

  _checkLoadMore(double overscroll) {
    double step =
        overscroll / ((_loadMoreDragOffset > widget.maxDragOffset) ? 3 : 1);
    _loadMoreDragOffset = _loadMoreDragOffset + (widget.reverse ? -step : step);
    if (_loadMoreDragOffset > widget.maxDragOffset &&
        _loadMoreStatus != LoadMoreIndicatorStatus.loading) {
      _loadMoreStatus = LoadMoreIndicatorStatus.arrived;
    }
  }

  _checkRefresh(double overscroll) {
    double step =
        overscroll / ((_refreshDragOffset > widget.maxDragOffset) ? 3 : 1);
    _refreshDragOffset = _refreshDragOffset + (widget.reverse ? step : -step);
    if (_refreshDragOffset > widget.maxDragOffset &&
        _refreshStatus != RefreshIndicatorStatus.refresh) {
      _refreshStatus = RefreshIndicatorStatus.arrived;
    }
  }

  bool _notifiListener(ScrollNotification notification) {
    switch (notification.runtimeType) {
      case ScrollStartNotification:
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
        if (_refreshDragOffset > widget.maxDragOffset &&
            _refreshStatus == RefreshIndicatorStatus.arrived) {
          _refreshDragOffset = widget.maxDragOffset;
          _notificationRefreshIndicator();
          _doRefresh();
        } else if (_refreshStatus != RefreshIndicatorStatus.refresh) {
          _putAwayRefresh();
        } else if (_refreshStatus == RefreshIndicatorStatus.refresh) {
          _refreshDragOffset = widget.maxDragOffset;
        }
        if (_loadMoreDragOffset > widget.maxDragOffset &&
            _loadMoreStatus == LoadMoreIndicatorStatus.arrived) {
          _loadMoreDragOffset = widget.maxDragOffset;
          _notificationRefreshIndicator();
          _doLoadMore();
        } else if (_loadMoreStatus != LoadMoreIndicatorStatus.loading) {
          _putAwayLoadMore();
        } else if (_loadMoreStatus == LoadMoreIndicatorStatus.loading) {
          _loadMoreDragOffset = widget.maxDragOffset;
        }
        break;
    }

    return false;
  }

  Future _doRefresh() async{
    _refreshStatus = RefreshIndicatorStatus.refresh;
    if (kDebugMode) {
      print("refresh");
    }
    widget.onRefresh?.call();
  }

  _doLoadMore() async{
    if (kDebugMode) {
      print("_doLoadMore");
    }
    _loadMoreStatus = LoadMoreIndicatorStatus.loading;
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
    _refreshStream
        .add(IndicatorStatusData(_refreshStatus, offset: _refreshDragOffset));
  }

  void _notificationLoadMoreIndicator() {
    _loadMoreStream
        .add(IndicatorStatusData(_refreshStatus, offset: _loadMoreDragOffset));
  }
}
