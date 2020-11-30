
import 'dart:async';
import 'dart:async';
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:major_project/models/profile_model.dart';
import 'package:major_project/models/markerpopup_model.dart';
import 'package:major_project/models/post_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final geo = Geoflutterfire();
  final String postCollectionReference = 'posts';
  final String profileCollectionReference = 'profiles';


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
  //every method calling imgurl needs to check null
  //add post
  Future<void> addPost({String username,String body, String userImgURL, String postImgURL, String uid, LatLng location}) {
    return _db
        .collection('posts')
        .doc()
        .set({
      "username":username ?? '',
      "body": body ?? '',
      "userImgURL":userImgURL ?? 'http://placekitten.com/200/300',
      "postImgURL":postImgURL ?? 'http://placekitten.com/200/300',
      "location": GeoPoint(location.latitude, location.longitude) ?? GeoPoint(0,0),
      "postedBy": uid ?? '',
      "postedDate": Timestamp.now() ?? 0,
    });
  }

  //getone
  Stream<Profile> streamProfile(String id) {
    return _db
        .collection('profiles')
        .doc(id)
        .snapshots()
        .map((snap) => Profile.fromFirestore(snap));
  }

  //getall
  Stream<List<Profile>> streamProfiles() {
    var ref = _db.collection('profiles');

    return ref.snapshots().map((list) =>
        list.docs.map(
                (doc) => Profile.fromFirestore(doc)
        ).toList());
  }
  //query within radius
  // Create a geoFirePoint
  Stream<List<DocumentSnapshot>> getProfilesInRadius(double radius){
  GeoFirePoint center = geo.point(latitude: 12.960632, longitude: 77.641603);//todo:change to curr loc
  Stream<List<DocumentSnapshot>> stream;
  double radius = 50;
  String field = 'position';
  var collectionReference = _db.collection('profile_locations');
  stream = geo.collection(collectionRef: collectionReference)
      .within(center: center, radius: radius, field: field);
  return stream;}

  //every method calling imgurl needs to check null
  //add user
  Future<void> addProfile({String uid, String username, String profileImgURL, LatLng location}) {
    return _db.collection('profiles')
        .doc(uid)
        .set({
      "username": username ?? 'Anonymous',
      "profileImgURL": profileImgURL ?? 'http://placekitten.com/200/300',
      "location": GeoPoint(location.latitude, location.longitude) ?? GeoPoint(0,0),
    });
  }
  //get profile
  Future<Profile> getProfile({String uid}) async{
    var snap = await _db.collection('profiles')
        .doc(uid)
        .get();
    return Profile.fromFirestore(snap);
  }
  //update profile
  Future<void> updateProfileUsername({String uid, String username}){
    return _db.collection('profiles')
        .doc(uid)
        .set({
      "username": username ?? 'Anonymous'
    });
  }
  //every method calling imgurl needs to check null
  //update profile image
  Future<void> updateProfileImage({String uid, String profileImgURL}){
    return _db.collection('profiles')
        .doc(uid)
        .set({
      "profileImgURL": profileImgURL ?? 'http://placekitten.com/200/300'
    });
  }


}