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
  // late final StreamController<RefreshAndLoadingEvent> _refreshIndicatorStream;
  late final RefreshLoadingController _refreshLoadingController;

  @override
  void initState() {
    super.initState();
    _refreshLoadingController = RefreshLoadingController();
    _onRefresh();
  }

  List<String> items = ["0","1", "2", "3", "4", "5", "6", "7", "8","9"];

  _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshLoadingController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));

    items.add((items.length ).toString());
    items.add((items.length ).toString());
    items.add((items.length ).toString());
    items.add((items.length ).toString());
    items.add((items.length ).toString());
    items.add((items.length ).toString());
    items.add((items.length ).toString());
    items.add((items.length ).toString());
    items.add((items.length ).toString());
    items.add((items.length ).toString());
    items.add((items.length ).toString());
    // items.add((items.length + 1).toString());
    // items.add((items.length + 2).toString());
    // items.add((items.length + 3).toString());
    // items.add((items.length + 4).toString());
    // items.add((items.length + 5).toString());
    // items.add((items.length + 6).toString());
    // items.add((items.length + 7).toString());
    // items.add((items.length + 8).toString());
    // items.add((items.length + 9).toString());
    // items.add((items.length + 10).toString());
    _refreshLoadingController.loadingCompleted();
    if (mounted) setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppRefresh(
          onRefresh: () async {
            _onRefresh();
          },
          cacheExtent: 100,
          onLoadingMore: _onLoading,
          controller: _refreshLoadingController,
          child: ListView.builder(
              shrinkWrap: true,
              primary: false,
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,

              itemExtent: 100.0,
              itemBuilder: (context, index) {
                print(index.toString());
                return Card(child: Center(child: Text(items[index])));
              })),
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
