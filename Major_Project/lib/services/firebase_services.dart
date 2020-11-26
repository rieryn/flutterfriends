import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:major_project/models/app_user_model.dart';
import 'dart:async';
import 'package:major_project/models/markerpopup_model.dart';
import 'package:major_project/models/post_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<Post> streamPost(String id) {
    return _db
        .collection('posts')
        .doc(id)
        .snapshots()
        .map((snap) => Post.fromFirestore(snap));
  }

  Stream<List<Post>> streamPosts() {
    var ref = _db.collection('posts');

    return ref.snapshots().map((list) =>
        list.docs.map((doc) => Post.fromFirestore(doc)).toList());
  }

  //add post
  Future<void> addPost(String username,String body, String userImgURL, String postImgURL, DocumentReference uid, LatLng location) {
    return _db.collection('posts').doc().set({
      "username":username,
      "body": body,
      "userImgURL":userImgURL,
      "postImgURL":postImgURL,
      "location": GeoPoint(location.latitude, location.longitude),
      "postedBy": uid,
      "postedDate": Timestamp.now(),
    });
  }
  //users
  //todo: update with firebase auth
  //getone
  Stream<AppUser> streamUser(String id) {
    return _db
        .collection('users')
        .doc(id)
        .snapshots()
        .map((snap) => AppUser.fromFirestore(snap));
  }

  //getall
  Stream<List<AppUser>> streamUsers() {
    var ref = _db.collection('users');

    return ref.snapshots().map((list) =>
        list.docs.map((doc) => AppUser.fromFirestore(doc)).toList());
  }

  //add user
  Future<void> addUser(String name, String image, LatLng location) {
    return _db.collection('users').doc().set({
      "name": name,
      "image": image,
      "location": location,
    });
  }

}