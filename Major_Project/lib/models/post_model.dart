import 'dart:html';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'user_comment_model.dart';

/* it's best to denormalize all the data so make sure you update users.posts every time you update posts and so on
* similarly, likes is a list of user id references, comments are stored in subcollection*/

class Post {
  final String postid;
  final String username;
  final String body;
  final String userImgURL;
  final String postImgURL;
  final LatLng location;
  final DocumentReference postedBy;
  final int numLikes;
  final Map comments;
  final DateTime postedDate;

  Post({
    //firebase docReference
    this.postid,
    this.postedBy,

    //firebase strings
    this.username,
    this.body,
    this.userImgURL,
    this.postImgURL,

    //firebase int
    this.numLikes,

    //firebase timestamp
    this.postedDate,

    //firebase subcollection
    this.comments,

    //firebase geopoint
    this.location,
  });
  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data as Map;
    double lat = data['location'].latitude ?? 0;
    double lng = data['location'].longitude ?? 0;
    DateTime parsedTimestamp = DateTime.parse(data['postedDate'].toDate().toString());
    //todo: add some logic to x minutes ago
    return Post(
      postid: doc.id,
      postedBy: data['postedBy'] ?? '',
      numLikes: data['numLikes'] ?? '',
      username: data['uid'] ?? '',
      comments: doc.reference.collection('comments').snapshots().map((list) =>
          list.docs.map((doc) => UserComment.fromFirestore(doc)).toList()) ?? '',
      body: data['desc'] ?? '',
      userImgURL: data['userimg'] ?? '',
      postImgURL: data['userimg'] ?? '',
      location: LatLng(lat, lng),
      postedDate: parsedTimestamp ?? '',
    );
  }
}