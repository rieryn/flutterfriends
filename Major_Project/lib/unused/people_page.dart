import 'package:flutter/material.dart';
import 'package:major_project/services/localdb/covid_db.dart';

class PeoplePage extends StatefulWidget {
  PeoplePage({Key key}) : super(key: key);
  @override
  _PeoplePageState createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
      FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/map');
          // Add your onPressed code here!
        },
      )
    );
  }
}
