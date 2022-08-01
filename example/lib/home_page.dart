import 'dart:async';
import 'package:example/app_refresh.dart';
import 'package:flutter/material.dart';
import 'package:refresh_and_loading/refresh_and_loading.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final StreamController<RefreshAndLoadingEvent> _refreshIndicatorStream;

  @override
  void initState() {
    super.initState();
    _refreshIndicatorStream =
        StreamController<RefreshAndLoadingEvent>.broadcast();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Column case"),
      ),
      body: AppRefresh(
        onRefresh: () async {
          Future.delayed(Duration(seconds: 2)).then((value) {
            _refreshIndicatorStream.add(const RefreshAndLoadingEvent(
                refreshIndicatorStatus: RefreshIndicatorStatus.done));
          });
        },
        onLoadingMore: () {
          Future.delayed(Duration(seconds: 2)).then((value) {
            _refreshIndicatorStream.add(const RefreshAndLoadingEvent(
                loadMoreIndicatorStatus: LoadMoreIndicatorStatus.done));
          });
        },
        refreshAndLoadMoreStream: _refreshIndicatorStream.stream,
        child: Column(children: [
          SizedBox(
            height: 60,
          ),
          ListView.builder(
            itemCount: 100,
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                height: 60,
                child: Text("$index"),
              );

            },
          )
        ]),
      ),
    );
  }
// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: AppBar(
//       title: Text("Refresh and loading"),
//     ),
//     body: RefreshAndLoadMore(
//
//         onRefresh: () async {
//           Future.delayed(Duration(seconds: 2)).then((value) {
//             _refreshIndicatorStream.add(const RefreshAndLoadingEvent(
//                 refreshIndicatorStatus: RefreshIndicatorStatus.done));
//           });
//         },
//         onLoadingMore: () {
//           Future.delayed(Duration(seconds: 2)).then((value) {
//             _refreshIndicatorStream.add(const RefreshAndLoadingEvent(
//                 loadMoreIndicatorStatus: LoadMoreIndicatorStatus.done));
//           });
//         },
//         refreshAndLoadMoreStream: _refreshIndicatorStream.stream,
//         child: CustomScrollView(
//           shrinkWrap: true,
//           physics: const BouncingScrollPhysics(),
//           slivers: [
//             const SliverToBoxAdapter(child: ARefreshIndicator()),
//             ...List<int>.generate(100, (int index) => index)
//                 .map((index) => SliverToBoxAdapter(
//               child: Container(
//                 height: 50,
//                 color: Colors.white,
//                 width: double.infinity,
//                 alignment: Alignment.center,
//                 child: Text("$index"),
//               ),
//             ))
//                 .toList(),
//             const SliverToBoxAdapter(child:  LoadingIndicator()),
//           ],
//         )),
//   );
// }
}
