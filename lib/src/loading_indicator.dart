part of refresh_and_loading;

class LoadingIndicator extends StatefulWidget {
  const LoadingIndicator({
    Key? key,
  }) : super(key: key);

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with TickerProviderStateMixin {
  RefreshAndLoadMoreState? refreshAndLoadMoreState;

  late double _maxLoadingDragOffset;
  late final AnimationController _animationController;
  bool _isDependencies = false;

  LoadMoreIndicatorStatus _loadMoreIndicatorStatus =
      LoadMoreIndicatorStatus.snap;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    refreshAndLoadMoreState =
        context.findAncestorStateOfType<RefreshAndLoadMoreState>();

    _maxLoadingDragOffset =
        refreshAndLoadMoreState!.widget.maxLoadingDragOffset;
    if (_isDependencies == false) {
      _isDependencies = true;
      refreshAndLoadMoreState?.loadMoreStream
          .listen((LoadingIndicatorStatusData event) {
        if (event.offset != null) {
          _animationController.value = event.offset!;
          _loadMoreIndicatorStatus = event.indicatorStatus;
        }
      });
    }
  }

  @override
  initState() {
    _animationController = AnimationController(
        vsync: this,
        lowerBound: 0.0,
        upperBound: 50.0,
        duration: const Duration(milliseconds: 1000));
  }

  @override
  Widget build(BuildContext context) {
    if (refreshAndLoadMoreState != null) {
      return AnimatedBuilder(
          animation: _animationController,
          builder: (BuildContext context, Widget? child) {
            double offset = _animationController.value;
            double progress = offset / _maxLoadingDragOffset;
            progress = progress > 1 ? 1 : progress;
            return Container(
              height: offset,
              alignment: Alignment.topCenter,
              padding: EdgeInsets.only(top: _maxLoadingDragOffset / 2 - 15),
              child: _loadMoreIndicatorStatus == LoadMoreIndicatorStatus.loading
                  ? const CupertinoActivityIndicator(radius: 15)
                  : CupertinoActivityIndicator.partiallyRevealed(
                      progress: progress,
                      radius: 15,
                    ),
              // child: const PullActivityIndicator(),
            );
          });
    } else {
      return const SizedBox();
    }
  }
}