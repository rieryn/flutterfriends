import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:major_project/services/firebase_authentication.dart';
import 'package:major_project/services/firebase_services.dart';
import 'package:major_project/views/components/sign_up_popup.dart';

import 'home_page/home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _db = FirebaseService();
  final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    String _email;
    String _password;
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlutterLogo(size: 150),
              SizedBox(height: 50),
              Row(children:[
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Email', hintText: 'email@org.com'),
                  onChanged: (String value) {
                    _email = value;
                  },
                ),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: 'Password', hintText: 'Enter password'),
                  onChanged: (String value) {
                    _password = value;
                  },
                ),
              ]),
              Row(children:[
                _signInButton(_email, _password),
                _registerButton(_email, _password),
              ]),
              _googleSignInButton(),
              _guestSignInButton(),
            ],
          ),
        ),
      ),
    );
  }
  //todo: move all this logic somewhere
  Widget _registerButton(_email, _password){
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () async {
        try {
          await _auth.createUserWithEmailAndPassword(
              email:_email,
              password:_password);
            } on FirebaseAuthException catch(e) {
          if (e.code == 'account-exists-with-different-credential') {
            // The account already exists with a different credential
            String email = e.email;
            AuthCredential pendingCredential = e.credential;
            // Fetch a list of what sign-in methods exist for the conflicting user
            List<String> userSignInMethods = await _auth.fetchSignInMethodsForEmail(email);
            if (userSignInMethods.first == 'google.com') {
              GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
              GoogleSignInAuthentication googleAuth = await googleUser.authentication;
              final GoogleAuthCredential credential = GoogleAuthProvider.credential(
                accessToken: googleAuth.accessToken,
                idToken: googleAuth.idToken,
              );
              // Sign the user in with the credential
              UserCredential userCredential = await _auth.signInWithCredential(credential);

              // Link the pending credential with the existing account
              await userCredential.user.linkWithCredential(pendingCredential);
              return;
            }// todo: and so on for every signinprovider

          }
            print('Failed with error code: ${e.code}');
          print(e.message);//todo: snackbar or something
        } catch (e) {
          print(e);
        }
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage("assets/google_logo.png"), height: 35.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Create an account',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  Widget _signInButton(_email, _password){
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () async {
        try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: _email,
              password: _password
          );
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found') { //todo:snackbar or red text
            print('No user found for that email.');
          } else if (e.code == 'wrong-password') {
            print('Wrong password');
          }
        }
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage("assets/google_logo.png"), height: 35.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Create an account',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  //todo: make a class they can extend and shove into components
  //todo: username prompt after registering

  Widget _guestSignInButton(){
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () async {
        await _auth.signInAnonymously();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage("assets/google_logo.png"), height: 35.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign in as Guest',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );

  }

  Widget _googleSignInButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () {
        signInWithGoogle().then((result) {
          if (result != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return HomePage();
                },
              ),
            );
          }
        });
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage("assets/google_logo.png"), height: 35.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}