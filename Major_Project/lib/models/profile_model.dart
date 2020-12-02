import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'user_comment_model.dart';

/* it's best to denormalize all the data so make sure you update users.posts every time you update posts and so on
* interests are stored as a giant string (cheap!)
* */



class Profile {
  final String profileId;
  final String username;
  final String profileImgURL;
  final String interests;
  final String about;
  final LatLng location;
  final double distance;

  Profile({
    this.profileId,
    this.username,
    this.profileImgURL,
    this.interests,
    this.about,
    this.location,
    this.distance,
  });
  factory Profile.fromFirestore(DistanceDocSnapshot doc) {
    Map data = doc.documentSnapshot.data();
    LatLng location = LatLng(doc.coordinates.longitude,doc.coordinates.latitude);

    return Profile(
      profileId: doc.documentSnapshot.id,
      username: data['username'] ?? 'Anonymous',
      profileImgURL: data['profileImgURL'] ?? 'https://placekitten.com/640/360',
      interests: data['interests'] ?? '',
      about: data['about'] ?? '',
      location: location ?? '',
      distance: doc.distance ?? 0,
    );
  }
  Set getMatches(List<String> myInterests){
    List<String> listInterests = interests.split(' ');
    return Set.from(myInterests).intersection(Set.from(listInterests));
  }
}