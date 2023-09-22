import 'package:flutter/material.dart';
//import '../../localizations.dart';
import '../../../utils/log.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SqueexePage extends StatefulWidget {
  @override
  _SqueexePageState createState() => _SqueexePageState();
}

class _SqueexePageState extends State<SqueexePage> with TickerProviderStateMixin {
  TabController tabController;

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 2, vsync: this);

    // ordersBloc.updateOrdersSwaps();

    // swapBloc.outIndexTab.listen((int onData) {
    //   if (mounted) setState(() => tabController.index = onData);
    // });
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const WebView(
        initialUrl: 'https://squeexe.com/preview/dashboard/dashboard.html',
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}