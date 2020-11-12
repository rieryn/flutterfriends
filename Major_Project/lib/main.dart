import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:major_project/cloud/sign_in.dart';
import 'package:major_project/navigation_controller.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  var _colour = Colors.blue;
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
                  primarySwatch: _colour,
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                ),
                // home: NavigationController(),
                home: UserSignIn(),
                routes: <String, WidgetBuilder>{
                  '/NavigationController': (BuildContext context) =>
                      NavigationController(),
                });
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}
