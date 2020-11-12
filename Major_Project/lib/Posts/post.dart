import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Post {
  String username;
  // TODO: use real location
  String location;
  String mainText;
  String image;
  int numLikes;
  List<String> comments;
  DocumentReference reference;
  DateTime postedDate;

  Post({
    this.username,
    this.location,
    this.mainText,
    this.image,
    this.numLikes,
    this.comments,
    this.postedDate,
  });

  Post.fromMap(Map<String, dynamic> map, {this.reference}) {
    this.username = map['useername'];
    this.location = map['location'];
    this.mainText = map['mainText'];
    this.image = map['image'];
    this.numLikes = map['numLikes'];
    this.comments = map['comments'];
    this.postedDate = DateTime.parse(map['postedDate']);
  }

  Map<String, dynamic> toMap() {
    return {
      'username': this.username,
      'location': this.location,
      'mainText': this.mainText,
      'image': this.image,
      'numLikes': this.numLikes,
      'comments': this.comments,
      'datePosted': this.postedDate.toString(),
    };
  }
}
