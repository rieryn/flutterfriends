import 'dart:async';

import 'package:meta/meta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:major_project/models/models.dart';

//todo: add user auth then change to aggregation queries
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  //put paths or collection names
  final String postCollection = 'Posts';
  final String checkInCollection = 'CheckIn';

//stream posts
  Stream<List<Post>> streamPosts() {
    var ref = _db.collection(postCollection);

    return ref.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Post.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> deletePost(String id) async {
    return _db.collection(postCollection).doc(id).delete();
  }

  Future addPost(Post post) {
    return _db.collection(postCollection).doc().set(post.toMap());
  }

  Stream<List<CheckIn>> streamCheckIn() {
    var ref = _db.collection(postCollection);

    return ref.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => CheckIn.fromMap(doc.data(), doc.id)).toList());
  }
}
