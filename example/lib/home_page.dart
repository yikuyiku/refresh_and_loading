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

  List<String> items = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];

  _onRefresh() async {
    // monitor network fetch
    print("refresh");
    items.clear();

    items.add((items.length).toString());
    items.add((items.length).toString());
    items.add((items.length).toString());
    items.add((items.length).toString());
    items.add((items.length).toString());
    items.add((items.length).toString());
    items.add((items.length).toString());
    items.add((items.length).toString());
    items.add((items.length).toString());
    items.add((items.length).toString());
    items.add((items.length).toString());

    await Future.delayed(Duration(milliseconds: 1000));
    _refreshLoadingController.refreshCompleted();
    setState(() {});
    // if (mounted) setState(() {});
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));

    items.add((items.length).toString());
    items.add((items.length).toString());
    items.add((items.length).toString());
    items.add((items.length).toString());
    items.add((items.length).toString());
    items.add((items.length).toString());
    items.add((items.length).toString());
    items.add((items.length).toString());
    items.add((items.length).toString());
    items.add((items.length).toString());
    items.add((items.length).toString());
    _refreshLoadingController.loadingCompleted();
    setState(() {});
    // if (mounted) setState(() {});
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
              itemExtent: 200.0,
              itemBuilder: (context, index) {
                // print(index.toString());
                return Card(child: Center(child: Text(items[index])));
              })),
    );
  }
}
