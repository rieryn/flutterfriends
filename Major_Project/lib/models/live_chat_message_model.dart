
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'user_comment_model.dart';

/* it's best to denormalize all the data so make sure you update users.posts every time you update posts and so on
* similarly, likes is a list of user id references, comments are stored in subcollection*/

class LiveChatMessage {
  final String id;
  final String text;
  final DateTime time;
  final Position location;


  LiveChatMessage({
    this.id,
    this.text,
    this.location,
    this.time,
  });
  factory LiveChatMessage.fromFirestore(DistanceDocSnapshot doc) {
    Map<String, dynamic> data = doc.documentSnapshot.data();
    Position position = Position(longitude: doc.coordinates.longitude,latitude: doc.coordinates.latitude);
    return LiveChatMessage(
        id: doc.documentSnapshot.id,
        text: data['text']?? '',
        time: DateTime.parse(data['time']) ?? '',
        location: position,
    );
  }
}