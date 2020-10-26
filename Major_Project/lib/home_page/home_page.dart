import 'package:major_project/home_page/all_posts_tab.dart';
import 'package:major_project/home_page/posts_tab.dart';
import 'package:major_project/home_page/check_ins_tab.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                leading: IconButton(
                  icon: Icon(Icons.camera),
                  onPressed: null,
                ),
                title: Text('Localize'),
                centerTitle: true,
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.chat_bubble),
                    onPressed: null,
                  )
                ],
                floating: true,
                pinned: true,
                snap: false,
                bottom: TabBar(
                  tabs: [
                    Tab(text: 'Feed'),
                    Tab(text: 'Posts'),
                    Tab(text: 'Check-ins'),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              AllPostsTab(),
              ThoughtsTab(),
              CheckInsTab(),
            ],
          ),
        ),
      ),
    );
  }
}
