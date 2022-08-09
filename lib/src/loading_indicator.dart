part of refresh_and_loading;

class LoadingIndicator extends StatefulWidget {
  const LoadingIndicator({Key? key, required this.endOfListWidget})
      : super(key: key);
  final Widget endOfListWidget;

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with TickerProviderStateMixin {
  RefreshAndLoadMoreState? refreshAndLoadMoreState;

  late double _maxLoadingDragOffset;
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

      _maxLoadingDragOffset =
          refreshAndLoadMoreState!.widget.maxLoadingDragOffset;

      if (refreshAndLoadMoreState!.widget.refreshLoadingController != null) {
        refreshLoadingController =
            refreshAndLoadMoreState!.widget.refreshLoadingController!;
        _animationController = AnimationController(
            vsync: this,
            lowerBound: _maxLoadingDragOffset,
            upperBound: _maxLoadingDragOffset*2,
            duration: const Duration(milliseconds: 1000));
        refreshAndLoadMoreState!
            .widget.refreshLoadingController?.loadMoreDragOffset
            .addListener(() {
          _animationController.value =
              refreshLoadingController.loadMoreDragOffset.value;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (refreshAndLoadMoreState != null) {
      return ValueListenableBuilder<LoadMoreIndicatorStatus>(
          valueListenable: refreshLoadingController.footerMode!,
          builder:
              (BuildContext context, loadMoreIndicatorStatus, Widget? child) {
            switch (loadMoreIndicatorStatus) {
              case LoadMoreIndicatorStatus.withoutNextPage:
                return widget.endOfListWidget;
              case LoadMoreIndicatorStatus.loading:
              case LoadMoreIndicatorStatus.drag:
              case LoadMoreIndicatorStatus.snap:
              case LoadMoreIndicatorStatus.arrived:
                return AnimatedBuilder(
                    animation: _animationController,
                    builder: (BuildContext context, Widget? child) {
                      double offset =
                          _animationController.value ;
                      double progress = offset / _maxLoadingDragOffset;
                      progress = progress > 1 ? 1 : progress;
                      return Container(
                        height: offset,
                        alignment: Alignment.topCenter,
                        padding: EdgeInsets.only(
                            top: _maxLoadingDragOffset / 2 - 15),
                        child: loadMoreIndicatorStatus ==
                                LoadMoreIndicatorStatus.loading ||loadMoreIndicatorStatus ==
                            LoadMoreIndicatorStatus.snap
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
