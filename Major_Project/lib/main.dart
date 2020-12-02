import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:major_project/services/firestore_services.dart';
import 'package:major_project/services/marker_bitmapper.dart';
import 'package:major_project/services/localdb/covid_db.dart';
import 'package:major_project/services/localdb/sqlite_services.dart';
import 'package:major_project/views/components/navigation_controller.dart';
import 'package:major_project/views/pages/chat_page/chat_page.dart';
import 'package:major_project/views/pages/login_page.dart';
import 'package:major_project/views/pages/map_page.dart';
import 'package:provider/provider.dart';

import 'models/chat_session_model.dart';
import 'models/markerpopup_model.dart';
import 'models/post_model.dart';
import 'models/profile_model.dart';
import 'models/settings_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  CovidDB.instance.init();
  //wrap in localdb init
    runApp(
      ChangeNotifierProvider<Settings>(
        create: (_) => Settings('blueTheme'),
        child: MyApp(),
      ),
    );
  //});
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  //initialize local database to load Theme settings to build the app
  @override
  void initState() {
    MarkerBitmapper.instance.init();
    WidgetsFlutterBinding.ensureInitialized();
  }

  @override
  Widget build(BuildContext context) {
    var _color;
    return FutureBuilder(
        //future builder to establish connecton to Cloud db
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Error initializing DB');
            return Text('Error initializing DB');
          }
          if (snapshot.connectionState == ConnectionState.done) {
            final db = FirebaseService();
            return MultiProvider(
                providers: [
                  //map marker provider, this really could be somewhere else
                  ChangeNotifierProvider(
                      create: (context) => MarkerPopupModel()),
                  //todo:decide where to put these later
                  //auth provider
                  StreamProvider<User>.value(value: FirebaseAuth.instance.authStateChanges()),
                  //posts provider
                  StreamProvider<List<Post>>.value(value: db.streamPosts()),

                ],
                child: MaterialApp(
                //builds app only is connection works
                title: 'Flutter Demo',
                theme: ThemeData(
                  primarySwatch: _color,
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                ),
                // home: NavigationController(),
                home: NavigationController(),
                routes: <String, WidgetBuilder>{
                  //named routes
                  '/home': (BuildContext context) => NavigationController(),
                  '/login': (BuildContext context) => LoginPage(),
                  '/chatPage': (BuildContext context) => ChatPage(),
                  '/map':(BuildContext context) => MapPage(),
                })
            );
          } else {
            return CircularProgressIndicator();
          }
        });
  }


}
