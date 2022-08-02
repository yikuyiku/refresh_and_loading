part of refresh_and_loading;

class RefreshLoadingController {
  RefreshLoadingController() {
    headerMode =
        ValueNotifier<RefreshIndicatorStatus>(RefreshIndicatorStatus.snap);
    footerMode =
        ValueNotifier<LoadMoreIndicatorStatus>(LoadMoreIndicatorStatus.snap);
  }

  ValueNotifier<RefreshIndicatorStatus>? headerMode;

  ValueNotifier<LoadMoreIndicatorStatus>? footerMode;

  refreshCompleted() {
    headerMode?.value = RefreshIndicatorStatus.done;
    headerMode?.value = RefreshIndicatorStatus.snap;
  }

  loadingCompleted(){
    footerMode?.value = LoadMoreIndicatorStatus.done;
  }
}
