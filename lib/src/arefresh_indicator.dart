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

  bool _isDependencies = false;
  late RefreshLoadingController refreshLoadingController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isDependencies == false) {
      _isDependencies = true;
      refreshAndLoadMoreState =
          context.findAncestorStateOfType<RefreshAndLoadMoreState>();
      _maxRefreshDragOffset =
          refreshAndLoadMoreState!.widget.maxRefreshDragOffset;
      if (refreshAndLoadMoreState!.widget.refreshLoadingController != null) {
        refreshLoadingController =
            refreshAndLoadMoreState!.widget.refreshLoadingController!;
        refreshLoadingController.refreshDragOffset.addListener(() {
          _animationController.value =
              refreshLoadingController.refreshDragOffset.value;
        });

        _animationController = AnimationController(
            lowerBound: 0,
            upperBound: _maxRefreshDragOffset * 2,
            vsync: this,
            duration: const Duration(milliseconds: 1000));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (refreshAndLoadMoreState != null) {
      return ValueListenableBuilder<RefreshIndicatorStatus>(
          valueListenable: refreshLoadingController.headerMode!,
          builder:
              (BuildContext context, refreshIndicatorStatus, Widget? child) {
            return AnimatedBuilder(
                animation: _animationController,
                builder: (BuildContext context, Widget? child) {
                  double offset = _animationController.value;
                  // double progress = math.min(offset / _maxRefreshDragOffset, 1);
                  double progress = math.min (offset / _maxRefreshDragOffset,1.0);
                  return Container(
                    height: offset,
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.only(bottom: 10),
                    child:
                        refreshIndicatorStatus == RefreshIndicatorStatus.refresh
                            ? const CupertinoActivityIndicator(radius: 15)
                            : CupertinoActivityIndicator.partiallyRevealed(
                                progress: progress,
                                radius: 15,
                              ),
                    // child: const PullActivityIndicator(),
                  );
                });
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
