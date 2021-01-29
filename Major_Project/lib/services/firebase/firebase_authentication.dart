import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:major_project/views/components/image_dialog.dart';
import 'package:major_project/views/components/navigation_controller.dart';
import 'package:major_project/views/pages/home_page/home_page.dart';
import 'package:major_project/views/pages/login_page/username_dialog.dart';
import 'package:provider/provider.dart';

import 'firebase_storage.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

import 'firestore_services.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();
final _db = FirebaseService();

Future<User> signInWithGoogle() async {
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final UserCredential authResult =
      await _auth.signInWithCredential(credential);
  final User user = authResult.user;

  if (user != null) {
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final User currentUser = _auth.currentUser;
    assert(user.uid == currentUser.uid);

    print('signInWithGoogle succeeded: $user');

    return user;
  }
  print('goodles signing failed');
  return null;
}

Future<void> firebaseAuthErrorHandler(FirebaseAuthException e) async {
  if (e.code == 'account-exists-with-different-credential') {
    String email = e.email ?? '';
    AuthCredential pendingCredential = e.credential;
    //fetch signin methods
    List<String> userSignInMethods =
        await _auth.fetchSignInMethodsForEmail(email);
    if (userSignInMethods.first == 'google.com') {
      GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final GoogleAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // link credentials
      await userCredential.user.linkWithCredential(pendingCredential);
      return;
    } // todo: and so on for every signinprovider

  }
  if (e.code == 'user-not-found') {
    //todo:snackbar or red text
    print('No user found for that email.');
  } else if (e.code == 'wrong-password') {
    print('Wrong password');
  }
  print('Failed with error code: ${e.code}');
  print(e.message); //todo: snackbar or something
}

registerAnonymous(context, {LocationData location}) async {
  try {
    await _auth.signInAnonymously();
    User _user = FirebaseAuth.instance.currentUser;
    updateUser(context, location: location);
    print(_user);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return NavigationController();
        },
      ),
    );
  } on FirebaseAuthException catch (e) {
    await firebaseAuthErrorHandler(e);
  } //todo: you can use the context here to push a error widget
  catch (e) {
    print(e);
  }
}

registerEmailPassword(context,
    {@required String email,
    @required String password,
    LocationData location}) async {
  try {
    await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await updateUser(context, location: location);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return NavigationController();
        },
      ),
    );
  } on FirebaseAuthException catch (e) {
    await firebaseAuthErrorHandler(e);
  } catch (e) {
    print(e);
  }
}

registerGoogle(context, {LocationData location}) async {
  try {
    User _user = await signInWithGoogle();
    print(_user);
    await updateUser(context, location: location);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return NavigationController();
        },
      ),
    );
  } on FirebaseAuthException catch (e) {
    await firebaseAuthErrorHandler(e);
  } catch (e) {
    print(e);
  }
}

updateUser(context, {LocationData location}) async {
  final User currentUser = _auth.currentUser;
  assert(await currentUser.getIdToken() != null);
  assert(currentUser.uid == currentUser.uid);
  final _username =
      await UsernameDialog.getUsername(context) ?? "Anonymous"; //todo ui
  final _photoURL = await ImagePickerDialog.getImgUrl(context) ?? ""; //todo ui
  await currentUser.updateProfile(
    displayName: _username,
    photoURL: _photoURL,
  );
  await _db.createProfile(
      uid: currentUser.uid,
      username: _username ?? 'Anonymous',
      profileImgURL: _photoURL);
  if (location != null) {
    await _db.updateProfileLocation(uid: currentUser.uid, location: location);
  }
  print("created profile");
  print(currentUser);
  currentUser.reload();
  print(_auth.currentUser);
}

Future<void> signOutAll(User user) async {
  print("signing out user");
  //todo: remember to reset user specific sharedprefs
  print(user);
  await _auth.signOut();
}

//todo: check what happens if you call this while not signed in with google
Future<void> signOutGoogle() async {
  await googleSignIn.signOut();
  print("User Signed Out");
}
