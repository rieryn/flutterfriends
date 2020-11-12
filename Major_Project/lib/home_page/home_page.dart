import 'package:major_project/Posts/add_post_popup.dart';
import 'package:major_project/Posts/post.dart';
import 'package:major_project/Posts/post_model.dart';
import 'package:major_project/home_page/all_posts_tab.dart';
import 'package:major_project/home_page/posts_tab.dart';
import 'package:major_project/home_page/check_ins_tab.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
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
                  snap: true,
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
          floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () async {
                Post post = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AddPostPopup();
                    });
                await PostModel.insertPost(post);
                Scaffold.of(context).showSnackBar(SnackBar(
                  duration: Duration(seconds: 1),
                  content: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text("Posted")]),
                ));
              })),
    );
  }
}
