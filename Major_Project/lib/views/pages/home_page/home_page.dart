import 'package:firebase_auth/firebase_auth.dart';
import 'package:major_project/models/post_model.dart';
import 'package:major_project/views/components/add_post_dialog.dart';
import 'package:major_project/views/pages/home_page/posts_tab.dart';
import 'package:provider/provider.dart';
import 'feed_tab.dart';
import 'check_ins_tab.dart';
import 'package:major_project/views/components/add_post_dialog.dart';
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
          drawer: Drawer(//profile

          ),
          endDrawer: Drawer(//settings, etc.

          ),
          body: NestedScrollView(
            // scroll should collapse app bar
            // scroll controller not working
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  // open camera
                  leading: IconButton(
                    icon: Icon(Icons.camera),
                    onPressed: null,
                  ),
                  // dope title
                  title: Text('Localize'),
                  centerTitle: true,
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(Icons.person),
                      onPressed: () async {
                        Navigator.pushNamed(context, '/UserSignIn');
                      },
                    ),
                    IconButton(
                      // settings menue
                      icon: Icon(Icons.settings),
                      onPressed: () {
                        _settings();
                      },
                    )
                  ],
                  floating: true,
                  pinned: true,
                  snap: true,
                ),
              ];
            },
            body: TabBarView(
              children: [
                FeedTab(),
                ThoughtsTab(),
                CheckInsTab(),
              ],
            ),
          ),
          // add post button
          floatingActionButton: FloatingActionButton(


              child: Icon(Icons.add),
              onPressed: () async {
                var user = Provider.of<User>(context, listen: false);
                bool loggedIn = user != null;
                if(loggedIn){
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return AddPostPopup();
                      },
                    ),
                  );//bring up add_post


                   }
                else{//else prompt login
                  Scaffold.of(context).showSnackBar(
                      SnackBar(
                        duration: Duration(seconds: 5),
                        content: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Text("Sign in or create an account to continue")]),
                  ));
                  Navigator.pushNamed(context, '/login');}
                Scaffold.of(context).showSnackBar(SnackBar(
                  duration: Duration(seconds: 1),
                  content: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text("Posted")]),
                ));
              })),
    );
  }

  // open settings page
  Future<void> _settings() async {
    Navigator.pushNamed(context, '/settings');
  }
}
