part of refresh_and_loading;

class LoadingIndicator extends StatefulWidget {
  const LoadingIndicator({
    Key? key,
  }) : super(key: key);

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator> {
  RefreshAndLoadMoreState? refreshAndLoadMoreState;

  late double _maxLoadingDragOffset;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    refreshAndLoadMoreState =
        context.findAncestorStateOfType<RefreshAndLoadMoreState>();

    _maxLoadingDragOffset =
        refreshAndLoadMoreState!.widget.maxLoadingDragOffset;
  }

  @override
  Widget build(BuildContext context) {
    if (refreshAndLoadMoreState != null) {
      return StreamBuilder<LoadingIndicatorStatusData>(
          stream: refreshAndLoadMoreState?.loadMoreStream,
          builder:
              (context, AsyncSnapshot<LoadingIndicatorStatusData> snapshot) {
            if (snapshot.hasData) {
              double offset = snapshot.data?.offset ?? 0;
              double progress = offset / _maxLoadingDragOffset;
              progress = progress > 1 ? 1 : progress;
              progress = progress == 0 ? 1 : progress;
              LoadMoreIndicatorStatus indicatorStatus =
                  snapshot.data!.indicatorStatus;
              return Container(
                height: offset,
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.only(bottom: 30),
                child: (indicatorStatus == LoadMoreIndicatorStatus.arrived ||
                        indicatorStatus == LoadMoreIndicatorStatus.loading)
                    ? const CupertinoActivityIndicator(radius: 15)
                    : CupertinoActivityIndicator.partiallyRevealed(
                        progress: progress,
                        radius: 15,
                      ),
                // child: const PullActivityIndicator(),
              );
            } else {
              return const SizedBox();
            }
          });
    }
    return const SizedBox();
  }
}
