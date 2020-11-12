import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:major_project/navigation_controller.dart';

class UserNames {
  String username;
  String password;

  UserNames({
    this.username,
    this.password,
  });

  getUserName(String username) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
  }

  DocumentReference reference;

  UserNames.fromMap(Map<String, dynamic> map, {this.reference}) {
    this.username = map['username'];
    this.password = map['password'];
  }
  Map<String, dynamic> toMap() {
    return {
      'username': this.username,
      'password': this.password,
    };
  }
}

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
        onPressed: () async {
          if (_formkey.currentState.validate()) {
            _formkey.currentState.save();
            await Firebase.initializeApp();
            await FirebaseFirestore.instance
                .collection('users')
                .where('username', isEqualTo: _userName)
                .get()
                .then((QuerySnapshot snapshot) => {
                      snapshot.docs.forEach((doc) {
                        if (doc["password"] == _password) {
                          Navigator.pushNamed(context, '/NavigationController');
                        } else {
                          print("No Match");
                        }
                      })
                    });
          }
        },
        child: Icon(Icons.check),
      ),
    );
  }
}
