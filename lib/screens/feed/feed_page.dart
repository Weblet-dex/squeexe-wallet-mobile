import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/feed/news/news_tab.dart';
import 'package:komodo_dex/utils/log.dart';

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage>
    with SingleTickerProviderStateMixin {
  TabController _controllerTabs;
  @override
  void initState() {
    _controllerTabs = TabController(length: 1, vsync: this);
    _controllerTabs.addListener(_getIndex);
    super.initState();
  }

  @override
  void dispose() {
    _controllerTabs.dispose();
    super.dispose();
  }

  void _getIndex() {
    Log.println('media_page:38', _controllerTabs.index);
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildAppBar() {
      return AppBar(
        title: Text(AppLocalizations.of(context).feedTitle.toUpperCase()),
        automaticallyImplyLeading: false,
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _controllerTabs,
        children: <Widget>[
          NewsTab(),
        ],
      ),
    );
  }
}
