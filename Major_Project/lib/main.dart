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
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Error initializing DB');
            return Text('Error initializing DB');
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return MaterialApp(
                title: 'Flutter Demo',
                theme: ThemeData(
                  primarySwatch: _color,
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                ),
                // home: NavigationController(),
                home: UserSignIn(),
                routes: <String, WidgetBuilder>{
                  '/NavigationController': (BuildContext context) =>
                      NavigationController(),
                  '/settings': (BuildContext context) => PickSetting(),
                });
          } else {
            return CircularProgressIndicator();
          }
        });
  }

  Future<Settings> _getSettings() async {
    Settings settings = await SettingsModel.readSettings();
    return settings;
  }
}
