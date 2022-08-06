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

  // LoadMoreIndicatorStatus _loadMoreIndicatorStatus =
  //     LoadMoreIndicatorStatus.snap;

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
        }
      });
    }
  }

  @override
  initState() {
    _animationController = AnimationController(
        vsync: this,
        // lowerBound: 0.0,
        // upperBound: 50.0,
        duration: const Duration(milliseconds: 1000));
  }

  @override
  Widget build(BuildContext context) {
    if (refreshAndLoadMoreState != null) {
      return ValueListenableBuilder<LoadMoreIndicatorStatus>(
          valueListenable: refreshAndLoadMoreState!
              .widget.refreshLoadingController!.footerMode!,
          builder: (BuildContext context, loadMoreIndicatorStatus, Widget? child) {
            switch (loadMoreIndicatorStatus) {
              case LoadMoreIndicatorStatus.withoutNextPage:
                return Container(
                  height: _maxLoadingDragOffset,
                  alignment: Alignment.center,
                  child: const Text("這已經是列表最底了"),
                );

              case LoadMoreIndicatorStatus.loading:
              case LoadMoreIndicatorStatus.drag:
              case LoadMoreIndicatorStatus.snap:
              case LoadMoreIndicatorStatus.arrived:
                print(loadMoreIndicatorStatus);
                return AnimatedBuilder(
                    animation: _animationController,
                    builder: (BuildContext context, Widget? child) {
                      print(loadMoreIndicatorStatus);
                      double offset =
                          _animationController.value * _maxLoadingDragOffset;
                      double progress = offset / _maxLoadingDragOffset;
                      progress = progress > 1 ? 1 : progress;
                      return Container(
                        height: offset,
                        alignment: Alignment.topCenter,
                        padding: EdgeInsets.only(
                            top: _maxLoadingDragOffset / 2 - 15),
                        child: loadMoreIndicatorStatus ==
                                LoadMoreIndicatorStatus.loading
                            ? const CupertinoActivityIndicator(radius: 15)
                            : CupertinoActivityIndicator.partiallyRevealed(
                                progress: progress,
                                radius: 15,
                              ),
                      );
                    });
              default:
                return const SizedBox();
            }
          });
    } else {
      return const SizedBox();
    }
  }
}
