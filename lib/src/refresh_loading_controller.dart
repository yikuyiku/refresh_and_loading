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
    headerMode?.value = RefreshIndicatorStatus.refresh;
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

  /// 加载结束
  void loadFinished({bool empty =false, bool noMore = false}) {
    if (empty) {
      /// 数据为空, 加载空视图
      emptyData();
    } else if (noMore) {
      /// 加载完成
      /// 没有更多了
      withoutNextPage();

      /// 隐藏loading
      refreshCompleted();
    } else {
      /// 说明还有数据, 可以继续加载
      loadingCompleted();

      /// 隐藏loading
      refreshCompleted();
    }
  }
  @Deprecated(
    'Use loadFinished instead.'
  )
  void loadFinish({dynamic data , bool noMore = false}) {
    if (data != null) {
      if (data is List) {
        if (data.isEmpty) {
          /// 数据为空, 加载空视图
          emptyData();
        } else if (noMore) {
          /// 加载完成
          /// 没有更多了
          withoutNextPage();

          /// 隐藏loading
          refreshCompleted();
        } else {
          /// 说明还有数据, 可以继续加载
          loadingCompleted();

          /// 隐藏loading
          refreshCompleted();
        }
      } else {
        /// 加载结束
        refreshCompleted();
      }
    } else {
      /// 加载结束, 没有更多
      refreshCompleted();
    }
  }
}
