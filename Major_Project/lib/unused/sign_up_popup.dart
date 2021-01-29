import 'package:flutter/material.dart';

class SignUpPopUp extends StatefulWidget {
  @override
  _SignUpPopUpState createState() => _SignUpPopUpState();
}

class _SignUpPopUpState extends State<SignUpPopUp> {
  final _formkey = GlobalKey<FormState>();
  String _username;
  String _password;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formkey,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 20,
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Username Field
              Container(
                padding: EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 4),
                child: TextFormField(
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: "Username",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(1.0)),
                      borderSide:
                          BorderSide(color: Theme.of(context).accentColor),
                    ),
                  ),
                  onSaved: (String value) {
                    _username = value;
                  },
                ),
              ),
              // Password field
              Container(
                  padding:
                      EdgeInsets.only(top: 4, left: 8, right: 8, bottom: 4),
                  child: TextFormField(
                    // no peeky
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(1.0)),
                        borderSide:
                            BorderSide(color: Theme.of(context).accentColor),
                      ),
                    ),
                    onSaved: (String value) {
                      _password = value;
                    },
                  )),
              // Sign up button. might need to move this UX is not great
              // I keep clicking it as if it was submit
              Container(
                padding: EdgeInsets.only(top: 4, bottom: 8),
                child: RaisedButton(
                    child: Text('Sign Up'),
                    onPressed: () {
                      if (_formkey.currentState.validate()) {
                        _formkey.currentState.save();
                        // push new user
                        /*Navigator.of(context).pop(User(
                          username: _username,
                          password: _password,
                          birthday: _birthday,
                        ));*/
                      }
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
