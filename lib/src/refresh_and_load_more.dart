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
  const RefreshAndLoadMore({
    Key? key,
    this.reverse = false,
    this.maxRefreshDragOffset = 80.0,
    this.maxLoadingDragOffset = 50.0,
    this.onRefresh,
    this.onLoadingMore,
    required this.child,
    required this.refreshAndLoadMoreStream,
  }) : super(key: key);
  final bool reverse;
  final double maxRefreshDragOffset;
  final double maxLoadingDragOffset;
  final Future Function()? onRefresh;
  final void Function()? onLoadingMore;
  final Widget child;
  final Stream<RefreshAndLoadingEvent> refreshAndLoadMoreStream;

  @override
  State<RefreshAndLoadMore> createState() => RefreshAndLoadMoreState();
}

class RefreshAndLoadMoreState extends State<RefreshAndLoadMore> {
  get refreshStream => _refreshStream.stream;

  get loadMoreStream => _loadMoreStream.stream;
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

  @override
  void initState() {
    super.initState();
    if (widget.onRefresh != null) {
      _refreshStream = StreamController<RefreshIndicatorStatusData>.broadcast();
    }
    if (widget.onLoadingMore != null) {
      _loadMoreStream = StreamController<LoadingIndicatorStatusData>.broadcast();
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



  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: _notifiListener,
      child: widget.child,
    );
  }

  _checkLoadMore(double overscroll) {
    double step =
        overscroll / ((_loadMoreDragOffset > widget.maxLoadingDragOffset) ? 3 : 1);
    _loadMoreDragOffset = _loadMoreDragOffset + (widget.reverse ? -step : step);
    if (_loadMoreDragOffset > widget.maxLoadingDragOffset &&
        _loadMoreStatus != LoadMoreIndicatorStatus.loading) {
      _loadMoreStatus = LoadMoreIndicatorStatus.arrived;
    }
  }

  _checkRefresh(double overscroll) {
    double step =
        overscroll / ((_refreshDragOffset > widget.maxRefreshDragOffset) ? 3 : 2);
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
        if(notification.scrollDelta!=null && notification.scrollDelta!<0){
            _checkRefresh(notification.scrollDelta??0);
        }
        if (notification.metrics.extentAfter > 0.0) {
          if (widget.reverse && widget.onLoadingMore != null) {
            _checkLoadMore(notification.scrollDelta??0);
          } else if (widget.onRefresh != null) {
            _checkRefresh(notification.scrollDelta??0);
          }
        } else if (notification.metrics.extentBefore > 0.0) {
          if (widget.reverse && widget.onRefresh != null) {
            _checkRefresh(notification.scrollDelta??0);
          } else if (widget.onLoadingMore != null) {
            _checkLoadMore(notification.scrollDelta??0);
          }
        }
        break;
      case OverscrollNotification:
        notification as OverscrollNotification;
        if (kDebugMode) {
          print("OverscrollNotification");
        }
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
    if (kDebugMode) {
      print("refresh");
    }
    widget.onRefresh?.call();
  }

  _doLoadMore() async {
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
        .add(RefreshIndicatorStatusData(_refreshStatus, offset: _refreshDragOffset));
  }

  void _notificationLoadMoreIndicator() {
    _loadMoreStream
        .add(LoadingIndicatorStatusData(_loadMoreStatus, offset: _loadMoreDragOffset));
  }
}
