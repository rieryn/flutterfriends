import 'package:flutter/material.dart';

class ThoughtsTab extends StatefulWidget {
  @override
  _ThoughtsTabState createState() => _ThoughtsTabState();
}

class _ThoughtsTabState extends State<ThoughtsTab>
    with AutomaticKeepAliveClientMixin<ThoughtsTab> {
  @override
  bool get wantKeepAlive => true;

  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        controller: _scrollController,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Text Post'),
            subtitle: Text('$index'),
          );
        });
  }
}
