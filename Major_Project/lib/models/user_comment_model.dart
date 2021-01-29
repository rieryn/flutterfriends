import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/* it's best to denormalize all the data so make sure you update users.posts every time you update posts and so on
* similarly, likes is a list of user id references, comments are stored in post document*/

class UserComment { //could add replies...
  final String commentId;
  final String username;
  final String body;
  final String userImgURL;
  final String commentImgURL;
  final LatLng location;
  final DocumentReference postedBy;
  final DocumentReference likedBy;


  UserComment({
    this.commentId,
    this.username,
    this.postedBy,
    this.likedBy,
    this.body,
    this.userImgURL,
    this.commentImgURL,
    this.location,
  });
  factory UserComment.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data as Map;
    double lat = data['location'].latitude ?? '';
    double lng = data['location'].longitude ?? '';
    return UserComment(
      commentId: doc.id,
      postedBy: data['postedBy'] ?? '',
      username: data['uid'] ?? '',

      body: data['desc'] ?? '',
      userImgURL: data['userimg'] ?? '',
      commentImgURL: data['userimg'] ?? '',
      location: LatLng(lat, lng),
    );
  }
}