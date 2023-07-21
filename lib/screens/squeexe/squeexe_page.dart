import 'package:flutter/material.dart';
//import '../../localizations.dart';
import '../../../utils/log.dart';

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
      appBar: AppBar(title: const Text('GeeksforGeeks')),
      body: const Center(
        child: Text(
          'Welcome to GeeksforGeeks!!!',
          style: TextStyle(
            color: Colors.black,
            fontSize: 40.0,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 10.0,
        child: const Icon(Icons.add),
        onPressed: () {
          Log.println('squeexe_page:43', 'from sqx page');
        },
      ),
    );
  }
}