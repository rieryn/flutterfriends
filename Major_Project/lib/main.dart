import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:major_project/services/firestore_services.dart';
import 'package:major_project/services/location_service.dart';
import 'package:major_project/services/marker_bitmapper.dart';
import 'package:major_project/services/localdb/covid_db.dart';
import 'package:major_project/services/firestore_services.dart';
import 'package:major_project/services/location_services.dart';
import 'package:major_project/services/marker_bitmapper.dart';
import 'package:major_project/services/localdb/covid_db.dart';
import 'package:major_project/services/localdb/sqlite_services.dart';
import 'package:major_project/views/components/navigation_controller.dart';
import 'package:major_project/views/pages/chat_page/chat_page.dart';
import 'package:major_project/views/pages/login_page.dart';
import 'package:major_project/views/pages/map_page.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';
import 'models/chat_session_model.dart';
import 'models/markerpopup_model.dart';
import 'models/post_model.dart';
import 'models/profile_model.dart';
import 'models/settings_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  CovidDB.instance.init();
  await LocationService.instance.init();
  //wrap in localdb init
    runApp(
      MultiProvider(
          providers: [
            StreamProvider<User>.value(
              value: FirebaseAuth.instance.authStateChanges()),
            ChangeNotifierProvider<Settings>(
              create: (_) => Settings('blueTheme'),
            ),
            StreamProvider<LocationData>.value(
              value: LocationService.instance.locationStream
            ),
          ],
          child: MyApp(),
      )

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
  }

  @override
  Widget build(BuildContext context) {
    String uid = Provider.of<User>(context).uid;
    LocationData location = context.watch<LocationData>();
    var _color;
    final db = FirebaseService();
    return MultiProvider(
        providers: [
          //map marker provider, this really could be somewhere else
          ChangeNotifierProvider(create: (context) => MarkerPopupModel()),
          //todo:decide where to put these later
          //auth provider
          StreamProvider<User>.value(
              value: FirebaseAuth.instance.authStateChanges()),
          //have to rewrite these
          StreamProvider<List<Post>>.value(value: db.streamPosts()),
          StreamProvider<List<Profile>>.value(
              value: db.streamProfilesInRadius(
                  radius: 50, currentLocation: location)),
          StreamProvider<List<ChatSession>>(
            create: (_) => db.streamChatSessions(uid),
          )
        ],
        child: MaterialApp(
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
              '/map': (BuildContext context) => MapPage(),
            }));
  }
}