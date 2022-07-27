part of refresh_and_loading;

class ARefreshIndicator extends StatefulWidget {
  const ARefreshIndicator({Key? key}) : super(key: key);

  @override
  State<ARefreshIndicator> createState() => _ARefreshIndicatorrState();
}

class _ARefreshIndicatorrState extends State<ARefreshIndicator> {
  RefreshAndLoadMoreState? refreshAndLoadMoreState;
  late double _maxRefreshDragOffset;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    refreshAndLoadMoreState =
        context.findAncestorStateOfType<RefreshAndLoadMoreState>();
    _maxRefreshDragOffset =
        refreshAndLoadMoreState!.widget.maxRefreshDragOffset;
  }

  @override
  Widget build(BuildContext context) {
    if (refreshAndLoadMoreState != null) {
      return StreamBuilder<RefreshIndicatorStatusData>(
          stream: refreshAndLoadMoreState?.refreshStream,
          builder:
              (context, AsyncSnapshot<RefreshIndicatorStatusData> snapshot) {
            if (snapshot.hasData) {
              double offset = snapshot.data!.offset ?? 0;
              double progress = offset / _maxRefreshDragOffset;
              progress = progress > 1 ? 1 : progress;
              RefreshIndicatorStatus indicatorStatus =
                  snapshot.data!.indicatorStatus;
              return Container(
                height: offset,
                alignment: Alignment.topCenter,
                padding: EdgeInsets.only(top: _maxRefreshDragOffset / 2 - 15),
                child: (indicatorStatus == RefreshIndicatorStatus.arrived ||
                        indicatorStatus == RefreshIndicatorStatus.refresh)
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
    } else {
      return const SizedBox();
    }
  }
}
