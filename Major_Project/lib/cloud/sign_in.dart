import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:major_project/navigation_controller.dart';

class UserSignIn extends StatefulWidget {
  @override
  _UserSignInState createState() => _UserSignInState();
}

class _UserSignInState extends State<UserSignIn> {
  final _formkey = GlobalKey<FormState>();
  String _userName = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Sign-In')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Form(
              key: _formkey,
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'UserName:', hintText: 'eg: JohnSmith'),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'You did not enter a User Name!';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (String value) {
                        _userName = value;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Password:',
                      ),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'You did not enter a Password!';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (String value) {
                        _password = value;
                      },
                      obscureText: true,
                    ),
                  ],
                ),
              )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formkey.currentState.validate()) {
            _formkey.currentState.save();
            _checkPassword(_userName, _password);
          }
        },
        child: Icon(Icons.check),
      ),
    );
  }

  void _checkPassword(String username, String password) async {
    print(username);
    var result = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    // check that user is in db
    print(result.docs);
    if (result.docs.length > 0) {
      if (result.docs.first['password'] == password) {
        //successful logiin
        Navigator.pushNamed(context, '/NavigationController');
      } else {
        //TODO alert? snackbar?
        print("Login Failed - Incorrect Password");
      }
    } else {
      //TODO snackbar? alert?
      print("Login Failed - User Not Found");
    }
  }
}
