import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

class UsernameDialog {
  static Future<String> getUsername(
    //dunno might reuse it
    BuildContext context,
  ) async {
    final value = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final size = MediaQuery.of(context).size;
        String _username;
        final User _user = Provider.of<User>(context);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 10),
              Text(FlutterI18n.translate(context, "login.pickusername")),
              TextFormField(
                textAlign:TextAlign.center,
                //can change to validate if you want
                decoration: new InputDecoration(hintText: "Enter Username"),
                initialValue: (_user != null)
                    ? _user?.displayName ?? 'Anonymous'
                    : 'Anonymous', //? ? ???? ?; : ?:??
                onChanged: (text) {
                  _username = text;
                },
              ),Row(children:<Widget>[
                Spacer(),
                 FlatButton(
                   height: size.height/20,
                  minWidth: size.width/4,
                  child: Text(FlutterI18n.translate(context, "login.confirm")),
                  onPressed: () {
                    Navigator.of(context).pop(_username);
                  },
                ),
                Spacer(),
                FlatButton(
                  height: size.height/20,
                  minWidth: size.width/4,
                  child: Text(FlutterI18n.translate(context, "login.cancel")),
                  onPressed: () {
                    Navigator.of(context).pop(_username); //it does it anyway!
                  },
                ),
                Spacer(),
              ],)
            ],
          ),
        );
      },
    );
    return (value != null) ? value : 'Anonymous';
  }
}
