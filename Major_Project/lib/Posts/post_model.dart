import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:major_project/Posts/post.dart';

class PostModel {
  static Future<void> insertPost(Post post) {
    FirebaseFirestore.instance.collection('posts').add(post.toMap());
  }
}
