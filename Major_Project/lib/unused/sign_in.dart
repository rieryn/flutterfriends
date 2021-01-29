import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/*
class UserSignIn extends StatefulWidget {
  @override
  _UserSignInState createState() => _UserSignInState();
}

class _UserSignInState extends State<UserSignIn> {
  //sign in page with a form
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
                    //two textfields - one for username, one for password
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Username:', hintText: 'eg: JohnSmith'),
                      validator: (String value) {
                        if (value.isEmpty) {
                          //validate user textfield
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
          Container(
              child: RaisedButton(
                  //Create new user function
                  child: Text('Sign Up'),
                  onPressed: () async {
                    User user = await showDialog(
                        //dialog to create new user
                        context: context,
                        builder: (BuildContext context) {
                          return SignUpPopUp();
                        });
                    if (user != null) {
                      await UserModel.insertUser(user);
                      Scaffold.of(context).showSnackBar(SnackBar(
                        duration: Duration(seconds: 1),
                        content: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Text("Signed Up")]),
                      ));
                    }
                  }))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // sign in user
        onPressed: () {
          if (_formkey.currentState.validate()) {
            //validate fields and perform onSaved
            _formkey.currentState.save();
            _checkPassword(_userName, _password);
          }
        },
        child: Icon(Icons.check),
      ),
    );
  }

  void _checkPassword(String username, String password) async {
    User target = await UserModel.findUser(username);
    // check that user is in db
    if (target != null) {
      if (target.password == password) {
        //successful login
        Navigator.pop(context);
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
*/