import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gmaps_test/models/models.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:gmaps_test/models/models.dart';

class FirebaseService {
  final Firestore _db = Firestore.instance;

  //posts
  //getone
  Stream<Post> streamPost(String id) {
    return _db
        .collection('posts')
        .document(id)
        .snapshots()
        .map((snap) => Post.fromFirestore(snap));
  }

  //getall
  Stream<List<Post>> streamPosts() {
    var ref = _db.collection('posts');

    return ref.snapshots().map((list) =>
        list.documents.map((doc) => Post.fromFirestore(doc)).toList());
  }
  //get curr state
  Future<List<Post>> mapPosts () async  {
    return await streamPosts().first;
  }
  //add post
  Future<void> addPost(String user,String desc, String userimg, LatLng location) {
    return _db.collection('posts').document().setData({
      "user":user,
      "desc": desc,
      "userimg":userimg,
      "location":location,
    });
  }
  //users
  //todo: update with firebase auth
  //getone
  Stream<User> streamUser(String id) {
    return _db
        .collection('users')
        .document(id)
        .snapshots()
        .map((snap) => User.fromFirestore(snap));
  }

  //getall
  Stream<List<User>> streamUsers() {
    var ref = _db.collection('users');

    return ref.snapshots().map((list) =>
        list.documents.map((doc) => User.fromFirestore(doc)).toList());
  }

  //add user
  Future<void> addUser(String name, String image, LatLng location) {
    return _db.collection('users').document().setData({
      "name": name,
      "image": image,
      "location": location,
    });
  }

}