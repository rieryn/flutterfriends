import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:major_project/services/localdb/covid_db.dart';
import 'package:provider/provider.dart';
import 'package:major_project/models/settings_model.dart';

class AboutTab extends StatefulWidget {
  AboutTab({Key key}) : super(key: key);
  @override
  _AboutTabState createState() => _AboutTabState();
}

class _AboutTabState extends State<AboutTab> {
  @override
  Widget build(BuildContext context) {
    User _user = context.watch<User>();
    //Settings _prefs = Provider.of<Settings>(context, listen:false);
    return ListView(
      //About
      padding: EdgeInsets.all(5),
      children: <Widget>[

        Row(children: <Widget>[
          Text(
            "About me",
            style: TextStyle(
              color: Colors.blueGrey[300],
            ),
          ),
          Expanded(child: Divider()),
        ]),
        Padding(padding: EdgeInsets.all(5), child: Text("Just an everyday hero")),
        Row(children: <Widget>[
          Text(
            "Tag some of your interests",
            style: TextStyle(
              color: Colors.blueGrey[300],
            ),
          ),
          Expanded(child: Divider()),
        ]),
      ],
    );
  }
}
