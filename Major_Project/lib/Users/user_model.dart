import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:major_project/Users/users.dart';

class UserModel {
  static Future<void> insertUser(User user) {
    FirebaseFirestore.instance.collection('users').add(user.toMap());
  }

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
