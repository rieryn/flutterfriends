import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:major_project/services/firebase_services.dart';
import 'package:major_project/services/localdb/settings.dart';
import 'file:///X:/git/major-group-project-mobile-group/Major_Project/lib/views/pages/sign_in.dart';
import 'file:///X:/git/major-group-project-mobile-group/Major_Project/lib/views/components/navigation_controller.dart';
import 'package:major_project/services/localdb/settings_model.dart';
import 'package:provider/provider.dart';

import 'models/post_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _color;

  //initialize local database to load Theme settings to build the app
  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();

    _getSettings().then((value) {
      setState(() {
        switch (value.color) {
          case "Blue":
            {
              _color = Colors.blue;
            }
            break;

          case "Deep Purple":
            {
              _color = Colors.deepPurple;
            }
            break;

          case "Amber":
            {
              _color = Colors.amber;
            }
            break;

          default:
            {
              _color = Colors.deepPurple;
            }
            break;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {

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
                home: UserSignIn(), //homepage is user signin
                routes: <String, WidgetBuilder>{
                  //named routes
                  '/NavigationController': (BuildContext context) =>
                      NavigationController(),
                  '/settings': (BuildContext context) => PickSetting(),
                })
            );
          } else {
            return CircularProgressIndicator();
          }
        });
  }

  //read local database for settings
  Future<Settings> _getSettings() async {
    Settings settings = await SettingsModel.readSettings();
    return settings;
  }
}
