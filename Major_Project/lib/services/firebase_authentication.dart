
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:major_project/services/firestore_services.dart';
import 'package:major_project/views/components/username_dialog.dart';
import 'package:major_project/views/pages/home_page/home_page.dart';
import 'package:provider/provider.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();
final _db = FirebaseService();

Future<String> signInWithGoogle() async {
  await Firebase.initializeApp();

  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final UserCredential authResult = await _auth.signInWithCredential(credential);
  final User user = authResult.user;

  if (user != null) {
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final User currentUser = _auth.currentUser;
    assert(user.uid == currentUser.uid);

    print('signInWithGoogle succeeded: $user');

    return '$user';
  }

  return null;
}

Future<void> signOutGoogle() async {
  await googleSignIn.signOut();

  print("User Signed Out");
}

Future<void> firebaseAuthErrorHandling(FirebaseAuthException e) async {
  if (e.code == 'account-exists-with-different-credential') {
    // The account already exists with a different credential
    String email = e.email ?? '';
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
  if (e.code == 'user-not-found') { //todo:snackbar or red text
    print('No user found for that email.');
  } else if (e.code == 'wrong-password') {
    print('Wrong password');
  }
  print('Failed with error code: ${e.code}');
  print(e.message);//todo: snackbar or something
}
void createUserSuccess(context) async{
  final _user = Provider.of<User>(context);
  final _username =  await UsernameDialog.getUsername(context);
  if (_user.displayName == null){_user.updateProfile(displayName:'Anonymous', photoURL: 'http://placekitten.com/200/300');}
  _db.addProfile(uid: _user.uid, username: _username ?? 'Anonymous', profileImgURL: 'http://placekitten.com/200/300', location: LatLng(0,0));
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) {
        return HomePage();
      },
    ),
  );
}
void updateUser(){

}
void updateProfile(){

}