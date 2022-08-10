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
  // /// 是否加载完毕
  // ValueNotifier<bool> loadEnd = ValueNotifier<bool>(false);
  //
  // /// 是否正在加载
  // ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  /// 加载结束
  void loadFinish({dynamic data, bool noMore = false}) {
    if (data != null) {
      if (data is List) {
        if (data.isEmpty) {
          /// 数据为空, 加载空视图
          emptyData();
        } else if (noMore) {
          /// 加载完成
          /// 没有更多了
          withoutNextPage();
        } else {
          /// 说明还有数据, 可以继续加载
          loadingCompleted();
        }
      } else {
        /// 加载结束
        refreshCompleted();
      }
    } else {
      /// 加载结束, 没有更多
      refreshCompleted();
    }

    /// 隐藏loading
    refreshCompleted();
  }
}
