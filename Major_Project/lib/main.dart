import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:major_project/localdb/settings.dart';
import 'package:major_project/localdb/settings_model.dart';
import 'package:major_project/sign-in/sign_in.dart';
import 'package:major_project/navigation_controller.dart';

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
            return MaterialApp(
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
                });
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
