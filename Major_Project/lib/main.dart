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
  }
}
