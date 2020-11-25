import 'package:flutter/material.dart';

class CheckInsTab extends StatefulWidget {
  @override
  _CheckInsTabState createState() => _CheckInsTabState();
}

class _CheckInsTabState extends State<CheckInsTab>
    with AutomaticKeepAliveClientMixin<CheckInsTab> {
  @override
  bool get wantKeepAlive => true;

  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.builder(
        controller: _scrollController,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Image Post'),
            subtitle: Text('$index'),
          );
        });
  }
}
