import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:major_project/services/firebase/firebase_authentication.dart';
import 'package:major_project/services/firebase/firestore_services.dart';
import 'package:major_project/services/utils/location_service.dart';
import 'package:major_project/views/components/navigation_controller.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';
import '../home_page/home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _db = FirebaseService();
  final _auth = FirebaseAuth.instance;
  String email;
  String password;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            width: size.width,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlutterLogo(size: 150),
                  SizedBox(height: 50),
                  SizedBox(
                    width: size.width / 2,
                    height: size.height / 5,
                    child: Column(children: [
                      Expanded(
                          child: TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Email', hintText: 'email@org.com'),
                        onChanged: (String value) {
                          email = value;
                        },
                      )),
                      Expanded(
                          child: TextFormField(
                        obscureText: true,
                        decoration: const InputDecoration(
                            labelText: 'Password', hintText: 'Enter password'),
                        onChanged: (String value) {
                          password = value;
                        },
                      )),
                    ]),
                  ),
                  SizedBox(
                      width: size.width,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _signInButton(),
                            SizedBox(width: size.width / 20),
                            _registerButton(),
                          ])),
                  SizedBox(height: size.height / 30),
                  _googleSignInButton(),
                  SizedBox(height: size.height / 35),
                  _guestSignInButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _registerButton() {
    print(email);
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () async {
        final locationData = LocationService.instance.currentLocation;
        await registerEmailPassword(context,
            email: email, password: password, location: locationData);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign up',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _signInButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () async {
        try {
          final locationData = LocationService.instance.currentLocation;
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          User user = context.read<User>();
          _db.updateProfileLocation(uid: user.uid, location: locationData);
          Navigator.pop(context);
          ;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found') {
            //todo:snackbar or red text
            Scaffold.of(context).showSnackBar(SnackBar(
              duration: Duration(seconds: 2),
              content: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(FlutterI18n.translate(context, "login.usernotfound"))
                  ]),
            ));
          } else if (e.code == 'wrong-password') {
            Scaffold.of(context).showSnackBar(SnackBar(
              duration: Duration(seconds: 2),
              content: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(FlutterI18n.translate(context, "login.wrongpass"))
                  ]),
            ));
          }
        }
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign in',
                style: TextStyle(
                  fontSize: 15,
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

  Widget _guestSignInButton() {
    return Container(
      width: 300,
      child: OutlineButton(
        splashColor: Colors.grey,
        onPressed: () async {
          final locationData = LocationService.instance.currentLocation;
          //todo: display signing in loader
          await registerAnonymous(context, location: locationData);
          User user = context.read<User>();
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        highlightElevation: 5,
        borderSide: BorderSide(color: Colors.grey),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.assignment_ind, size: 35.0),
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
      ),
    );
  }

  Widget _googleSignInButton() {
    return Container(
      width: 300,
      child: OutlineButton(
        splashColor: Colors.grey,
        onPressed: () async {
          final locationData = LocationService.instance.currentLocation;

          await registerGoogle(context, location: locationData);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        highlightElevation: 0,
        borderSide: BorderSide(color: Colors.grey),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(
                  image: AssetImage("assets/images/google_logo.png"),
                  height: 35.0),
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
      ),
    );
  }
}
