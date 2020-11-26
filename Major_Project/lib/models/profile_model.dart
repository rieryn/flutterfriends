import 'dart:html';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'user_comment_model.dart';

/* it's best to denormalize all the data so make sure you update users.posts every time you update posts and so on
* similarly, likes is a list of user id references, comments are stored in subcollection*/



class Profile {
  final String profileId;
  final String username;
  final String profileImgURL;
  final LatLng location;

  Profile({
    this.profileId,
    this.username,
    this.profileImgURL,
    this.location,
  });
  factory Profile.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data as Map;

    return Profile(
      profileId: doc.id,
      username: data['username'] ?? '',
      profileImgURL: data['profileImgURL'] ?? '',
      location: data['location'] ?? '',
    );
  }
}