import 'package:firebase_auth/firebase_auth.dart';
import 'package:floating_search_bar/floating_search_bar.dart';
import 'package:lottie/lottie.dart';
import 'package:major_project/models/post_model.dart';
import 'package:major_project/views/components/add_post_bottomsheet.dart';
import 'package:major_project/views/components/add_post_dialog.dart';
import 'package:major_project/views/components/profile_drawer.dart';
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
          drawer: Drawer(child:ProfileDrawer()
          ),
          endDrawer: Drawer(//settings, etc.

          ),
          body: CustomScrollView(
            slivers: <Widget>[
          const SliverFloatingBar(
            trailing: Text("test"),
          pinned: true,
              floating:true,

              title: Text('test2'),
            ),
              SliverToBoxAdapter(
                child: Container(
                      child:FeedTab(),
                      height: MediaQuery.of(context).size.height*0.6,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.green,
                    ),

                    ),
              SliverToBoxAdapter(
                child: Container(
                  child: Lottie.asset('test_animation.json'),
                  height: MediaQuery.of(context).size.height*0.3,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.green,
                ),

              )
                  ],
                ),


          // add post button
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton.extended(
              icon: Icon(Icons.add),
              label: Text("create new post..."),
              backgroundColor: Colors.green,//try to make it look like bottomsheet
              onPressed: () async {
                var user = Provider.of<User>(context, listen: false);
                bool loggedIn = user != null;
                if(loggedIn){ //bring up addpost
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
