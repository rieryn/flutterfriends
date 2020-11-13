import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:major_project/Users/users.dart';

class UserModel {
  //static function that is called to insert new user to the cloud db
  static Future<void> insertUser(User user) {
    FirebaseFirestore.instance.collection('users').add(user.toMap());
  }

  //static function that is called to read password when user tries to log in
  static Future<User> findUser(String username) async {
    var result = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    if (result.docs.length > 0) {
      return User.fromMap(result.docs[0].data());
    } else {
      return null;
    }
  }
}
