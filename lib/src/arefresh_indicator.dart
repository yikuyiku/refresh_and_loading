part of refresh_and_loading;

class ARefreshIndicator extends StatefulWidget {
  const ARefreshIndicator({Key? key}) : super(key: key);

  @override
  State<ARefreshIndicator> createState() => _ARefreshIndicatorrState();
}

class _ARefreshIndicatorrState extends State<ARefreshIndicator>
    with TickerProviderStateMixin {
  RefreshAndLoadMoreState? refreshAndLoadMoreState;
  late double _maxRefreshDragOffset;
  late final AnimationController _animationController;
  RefreshIndicatorStatus _refreshIndicatorStatus = RefreshIndicatorStatus.snap;

  bool _isDependencies = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isDependencies == false) {
      _isDependencies = true;
      refreshAndLoadMoreState =
          context.findAncestorStateOfType<RefreshAndLoadMoreState>();
      _maxRefreshDragOffset =
          refreshAndLoadMoreState!.widget.maxRefreshDragOffset;
      refreshAndLoadMoreState?.refreshStream
          .listen((RefreshIndicatorStatusData event) {
        if (event.offset != null) {
          _animationController.value = event.offset!;
          _refreshIndicatorStatus = event.indicatorStatus;
        }
      });
      _animationController = AnimationController(
          lowerBound: 0,
          upperBound: _maxRefreshDragOffset * 2,
          vsync: this,
          duration: const Duration(milliseconds: 1000));
    }
  }

  @override
  initState() {}

  @override
  Widget build(BuildContext context) {
    if (refreshAndLoadMoreState != null) {
      return AnimatedBuilder(
          animation: _animationController,
          builder: (BuildContext context, Widget? child) {
            double offset = _animationController.value;
            double progress = offset / _maxRefreshDragOffset;
            progress = progress > 1 ? 1 : progress;
            return Container(
              height: offset,
              alignment: Alignment.center,
              child: _refreshIndicatorStatus == RefreshIndicatorStatus.refresh
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

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }
}
