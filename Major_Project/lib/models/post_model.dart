import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'user_comment_model.dart';

/* it's best to denormalize all the data so make sure you update users.posts every time you update posts and so on
* similarly, likes is a list of user id references, comments are stored in subcollection*/

class Post {
  final DocumentReference postid;
  final String username;
  final String body;
  final String userImgURL;
  final String postImgURL;
  final LatLng location;
  final String postedBy;
  final List<dynamic> likes;
  final String type;
  final String addressName;
  //final Map comments;
  final DateTime postedDate;
  final double distance;
  Post({
    //firebase docReference
    this.postid,
    this.postedBy,

    //firebase strings
    this.username,
    this.body,
    this.userImgURL,
    this.postImgURL,
    this.type,
    this.addressName,

    //firebase int
    this.likes,

    //firebase timestamp
    this.postedDate,

    //firebase subcollection
    // this.comments,

    //firebase geopoint
    this.location,
    this.distance,
  });

  factory Post.fromFirestore(DistanceDocSnapshot doc) {
    Map<String, dynamic> data = doc.documentSnapshot.data();
    double lat = doc.coordinates.latitude ?? 0;
    double lng = doc.coordinates.longitude ?? 0;
    //DateTime parsedTimestamp = DateTime.parse(data['postedDate'].toDate().toString());
    //todo: add some logic to x minutes ago
    return Post(
      postid: doc.documentSnapshot.reference,
      postedBy: data['postedBy'] ?? '',
      type: data['type'] ?? 'Post',
      addressName: data['addressName'],

      likes: data['likes'] ?? [],
      username: data['username'] ?? '',
      /*comments: doc.reference.collection('comments').snapshots().map((list) =>
          list.docs.map((doc) => UserComment.fromFirestore(doc)).toList()) ?? ''*/
      body: data['body'] ?? '',
      userImgURL: data['userImgURL'] ?? '',
      postImgURL: data['postImgURL'] ?? '',
      location: LatLng(lat, lng),
      //postedDate: parsedTimestamp ?? '',
      distance: doc.distance ?? 0,
    );
  }
  factory Post.fromFirebase(QueryDocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data();
    //DateTime parsedTimestamp = DateTime.parse(data['postedDate'].toDate().toString());
    //todo: add some logic to x minutes ago
    return Post(
      postid: doc.reference,
      postedBy: data['postedBy'] ?? '',
      type: data['type'] ?? 'Post',
      addressName: data['addressName'],

      likes: data['likes'] ?? [],
      username: data['username'] ?? '',
      /*comments: doc.reference.collection('comments').snapshots().map((list) =>
          list.docs.map((doc) => UserComment.fromFirestore(doc)).toList()) ?? ''*/
      body: data['body'] ?? '',
      userImgURL: data['userImgURL'] ?? '',
      postImgURL: data['postImgURL'] ?? '',
      //postedDate: parsedTimestamp ?? '',
    );
  }
}

class Likes {
  String body;
  int likes;

  Likes({this.body, this.likes});

  String toString() {
    return 'GradeFrequency($body, $likes)';
  }
}
