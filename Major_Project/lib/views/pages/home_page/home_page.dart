import 'package:firebase_auth/firebase_auth.dart';
import 'package:floating_search_bar/floating_search_bar.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:location/location.dart';
import 'package:lottie/lottie.dart';
import 'package:major_project/models/post_model.dart';
import 'package:major_project/views/components/profile_drawer.dart';
import 'package:major_project/views/pages/home_page/posts_tab.dart';
import 'package:provider/provider.dart';
import 'components/add_post_bottomsheet.dart';
import 'feed_tab.dart';
import 'check_ins_tab.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    LocationData locationData =
        Provider.of<LocationData>(context, listen: true);
    List<Post> postlist = context.watch<List<Post>>();
    var _user = Provider.of<User>(context, listen: true);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          drawer: Drawer(child: ProfileDrawer()),
          endDrawer: Drawer(//settings, etc.
              ),
          body: NestedScrollView(
              // scroll should collapse app bar
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    // we need a dope title
                    title: Text(
                      FlutterI18n.translate(context, "title.title"),
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    centerTitle: true,
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(Icons.person),
                        onPressed: () async {
                          if (_user == null) {
                            Navigator.pushNamed(context, '/login');
                          } else {
                            Scaffold.of(context).showSnackBar(SnackBar(
                              duration: Duration(seconds: 2),
                              content: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(FlutterI18n.translate(
                                        context, "snackbar.signedin"))
                                  ]),
                            ));
                          }
                        },
                      ),
                    ],
                    floating: true,
                    pinned: true,
                    snap: true,
                    bottom: TabBar(
                      tabs: [
                        Tab(
                            text: FlutterI18n.translate(
                                context, "homepage.feed")),
                        Tab(
                            text: FlutterI18n.translate(
                                context, "homepage.checkin")),
                      ],
                    ),
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  FeedTab(),
                  CheckInTab(),
                ],
              )),
          // add post button
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton.extended(
              icon: Icon(Icons.add),
              label: Text(FlutterI18n.translate(context, "homepage.post")),
              backgroundColor: Theme.of(context).accentColor,
              onPressed: () async {
                var user = Provider.of<User>(context, listen: false);
                bool loggedIn = user != null;
                if (loggedIn) {
                  //bring up addpost
                  showBottomSheet(
                    context: context,
                    builder: (context) => SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: AddPostBottomsheet(),
                      ),
                    ),
                  );
                } else {
                  //else prompt login
                  Scaffold.of(context).showSnackBar(SnackBar(
                    duration: Duration(seconds: 5),
                    content: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(FlutterI18n.translate(context, "drawer.signin"))
                        ]),
                  ));
                  Navigator.pushNamed(context, '/login');
                }
              })),
    );
  }

  // open settings page
  Future<void> _settings() async {
    Navigator.pushNamed(context, '/settings');
  }
}
