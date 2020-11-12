import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:major_project/Users/users.dart';

class UserModel {
  Future<void> insertUser(User user) {
    FirebaseFirestore.instance.collection('posts').add(user.toMap());
  }

  Future<User> findUser(String username) async {
    var result = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return User.fromMap(result.docs[0].data());
  }
}
