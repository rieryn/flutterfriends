import 'dart:html';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'user_comment_model.dart';

/* it's best to denormalize all the data so make sure you update users.posts every time you update posts and so on
* similarly, likes is a list of user id references, comments are stored in subcollection*/



class AppUser {
  final String userid;
  final String name;
  final String image;
  final LatLng location;

  AppUser({
    this.userid,
    this.name,
    this.image,
    this.location,
  });
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data as Map;

    return AppUser(
      userid: doc.id,
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      location: data['location'] ?? '',
    );
  }
}