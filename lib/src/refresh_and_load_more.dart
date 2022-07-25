
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

///指示器类型
enum IndicatorType { refresh, loadMore }

class RefreshAndLoadMore extends StatefulWidget {
  const RefreshAndLoadMore(
      {Key? key,
        this.reverse = false,
        this.maxDragOffset = 80.0,
        this.onRefresh,
        this.onLoadingMore})
      : super(key: key);
  final bool reverse;
  final double maxDragOffset;
  final void Function()? onRefresh;
  final void Function()? onLoadingMore;

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
    value = math.max(0.0, math.min(value, widget.maxDragOffset*3));
    _loadMoreDragOffsetValue = value;
    _notificationLoadMoreIndicator();
  }

  @override
  void initState() {
    super.initState();
    _refreshStream = StreamController<IndicatorStatusData>.broadcast();
    _loadMoreStream = StreamController<IndicatorStatusData>.broadcast();
  }

  _buildRefresh() {
    return SliverToBoxAdapter(
      child: StreamBuilder<IndicatorStatusData>(
          stream: _refreshStream.stream,
          builder: (context, AsyncSnapshot<IndicatorStatusData> snapshot) {
            double offset = snapshot.data?.offset ?? 0;
            double progress = offset / widget.maxDragOffset;
            progress = progress > 1 ? 1 : progress;
            progress = progress == 0 ? 1 : progress;
            return Container(
              height: offset,
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: 30),
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
    return  NotificationListener(
          onNotification: _notifiListener,
          child: Column(children: [
            if (widget.reverse) _buildLoadMore() else _buildRefresh(),
            ...List<int>.generate(100, (int index) => index)
                .map((index) => SliverToBoxAdapter(
              child: Container(
                height: 50,
                color: Colors.white,
                width: double.infinity,
                alignment: Alignment.center,
                child: Text("$index"),
              ),
            ))
                .toList(),
            if (widget.reverse) _buildRefresh() else _buildLoadMore(),
          ]),
        );
  }

  bool _notifiListener(ScrollNotification notification) {
    switch (notification.runtimeType) {
      case ScrollStartNotification:
      //   if (widget.reverse
      //       ? notification.metrics.extentAfter == 0.0
      //       : notification.metrics.extentBefore == 0.0) {
      //     _refreshStatus = IndicatorStatus.drag;
      //   }
      //   break;
      // case ScrollUpdateNotification:
      //   notification as ScrollUpdateNotification;
      //   if (_refreshStatus == IndicatorStatus.drag) {
      //     if (widget.reverse) {
      //       _refreshDragOffset =
      //           (_refreshDragOffset ?? 0) + notification.scrollDelta!;
      //     } else {
      //       _refreshDragOffset =
      //           (_refreshDragOffset ?? 0) - notification.scrollDelta!;
      //     }
      //     if (_refreshDragOffset?.floor() == widget.maxDragOffset) {
      //       _refreshStatus = IndicatorStatus.arrived;
      //     }
      //   }
        break;
      case OverscrollNotification:
        notification as OverscrollNotification;
        if (notification.metrics.extentAfter > 0.0) {
          if (widget.reverse && widget.onLoadingMore != null) {
            _loadMoreDragOffset = _loadMoreDragOffset + notification.overscroll;
            if (_loadMoreDragOffset > widget.maxDragOffset) {
              _loadMoreStatus = LoadMoreIndicatorStatus.arrived;
            }
          } else if (widget.onRefresh != null) {
            _refreshDragOffset = (_refreshDragOffset) -
                notification.overscroll /
                    ((_refreshDragOffset > widget.maxDragOffset) ? 3 : 1);
            if (_refreshDragOffset > widget.maxDragOffset) {
              _refreshStatus = RefreshIndicatorStatus.arrived;
            }
          }
        } else if (notification.metrics.extentBefore > 0.0) {
          if (widget.reverse && widget.onRefresh != null) {
            _refreshDragOffset = (_refreshDragOffset) +
                notification.overscroll /
                    ((_refreshDragOffset > widget.maxDragOffset) ? 3 : 1);
            if (_refreshDragOffset > widget.maxDragOffset) {
              _refreshStatus = RefreshIndicatorStatus.arrived;
            }
          } else if (widget.onLoadingMore != null) {
            _loadMoreDragOffset = _loadMoreDragOffset + notification.overscroll;
            if (_loadMoreDragOffset > widget.maxDragOffset) {
              _loadMoreStatus = LoadMoreIndicatorStatus.arrived;
            }
          }
        }
        break;
      case ScrollEndNotification:
        print("ScrollEndNotification");

        if (_refreshStatus == RefreshIndicatorStatus.arrived || _loadMoreStatus == LoadMoreIndicatorStatus.loading) {
          _refreshDragOffset = widget.maxDragOffset;
          _notificationRefreshIndicator();
          _doRefresh();
        } else {
          _putAwayRefresh();
        }
        if (_loadMoreStatus == LoadMoreIndicatorStatus.arrived || _loadMoreStatus == LoadMoreIndicatorStatus.loading) {
          _loadMoreDragOffset = widget.maxDragOffset;
          _notificationRefreshIndicator();
          _doLoadMore();
        } else {
          _putAwayLoadMore();
        }
        break;
    }
    return false;
  }

  _doRefresh() {
    _refreshStatus = RefreshIndicatorStatus.refresh;
    widget.onRefresh?.call();
  }

  _doLoadMore() {
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
