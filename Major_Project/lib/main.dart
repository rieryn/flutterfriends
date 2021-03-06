import 'package:animated_splash/animated_splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:major_project/services/firestore_services.dart';
import 'package:major_project/services/location_service.dart';
import 'package:major_project/services/marker_bitmapper.dart';
import 'package:major_project/services/localdb/covid_db.dart';
import 'package:major_project/services/firestore_services.dart';
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
import 'package:flare_splash_screen/flare_splash_screen.dart';

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
            StreamProvider<LocationData>.value(
              value: LocationService.instance.locationStream
            ),
          ],
          child: MyApp(),
      )
    );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    //async load things like bitmap images
    MarkerBitmapper.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    String uid;
    if(user != null){uid = user.uid;}
    LocationData location = context.watch<LocationData>();
    final db = FirebaseService();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Settings()),
        //map marker provider, this really could be somewhere else
        ChangeNotifierProvider(create: (context) => MarkerPopupModel()),
        //todo:decide where to put these later
        //have to rewrite these to be mutable
        StreamProvider<List<Post>>.value(
            value: db.streamPostsInRadius(
                radius: 2550, currentLocation: location)),
        StreamProvider<List<Profile>>.value(
            value: db.streamProfilesInRadius(
                radius: 2550, currentLocation: location)),
        StreamProvider<List<ChatSession>>(
          create: (_) => db.streamChatSessions(uid),
        )
      ],
      child: Consumer<Settings>(builder: (context, settings, child) {
        return MaterialApp(
            title: 'Flutter Demo',
            theme: settings.getTheme(),
            home: SplashScreen.navigate(
              name: 'assets/intro.flr',
              loopAnimation:'assets/intro.flr',
              next: (_) => NavigationController(),
              until: () => Future.delayed(Duration(seconds: 10)),
              startAnimation: '1',
            ),
            routes: <String, WidgetBuilder>{
              //named routes
              '/home': (BuildContext context) => NavigationController(),
              '/login': (BuildContext context) => LoginPage(),
              '/chatPage': (BuildContext context) => ChatPage(),
              '/map': (BuildContext context) => MapPage(),
            });
      }),
    );
  }
  Function duringSplash = () {
    return;
  };
}