import 'package:flutter/material.dart';

class AllPostsTab extends StatefulWidget {
  @override
  _AllPostsTabState createState() => _AllPostsTabState();
}

class _AllPostsTabState extends State<AllPostsTab>
    with AutomaticKeepAliveClientMixin<AllPostsTab> {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(itemBuilder: (context, index) {
      return ListTile(
        title: Text('Mixed Post'),
        subtitle: Text('$index'),
      );
    });
  }
}
