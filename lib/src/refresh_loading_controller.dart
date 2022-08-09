part of refresh_and_loading;

class RefreshLoadingController {
  RefreshLoadingController() {
    headerMode =
        ValueNotifier<RefreshIndicatorStatus>(RefreshIndicatorStatus.snap);
    footerMode =
        ValueNotifier<LoadMoreIndicatorStatus>(LoadMoreIndicatorStatus.snap);
    loadMoreDragOffset = ValueNotifier<double>(0);
    refreshDragOffset = ValueNotifier<double>(0);
  }

  ValueNotifier<RefreshIndicatorStatus>? headerMode;

  ValueNotifier<LoadMoreIndicatorStatus>? footerMode;
  late ValueNotifier<double> loadMoreDragOffset;
  late ValueNotifier<double> refreshDragOffset;

  refreshCompleted() {
    headerMode?.value = RefreshIndicatorStatus.done;
    headerMode?.value = RefreshIndicatorStatus.snap;
  }

  requestRefresh() {
    footerMode?.value = LoadMoreIndicatorStatus.snap;
  }

  loadingCompleted() {
    footerMode?.value = LoadMoreIndicatorStatus.done;
  }

  withoutNextPage() {
    footerMode?.value = LoadMoreIndicatorStatus.withoutNextPage;
  }

  emptyData() {
    headerMode?.value = RefreshIndicatorStatus.empty;
  }
}
