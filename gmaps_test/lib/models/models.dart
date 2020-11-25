import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';




class Post {
  final String postid;
  final String user;
  final String desc;
  final String userimg;
  final LatLng location;

  Post({
    this.postid,
    this.user,
    this.desc,
    this.userimg,
    this.location,
  });
  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;
    double lat = data['location'].latitude ?? '';
    double lng = data['location'].longitude ?? '';
    return Post(
        postid: doc.documentID,
        user: data['uid'] ?? '',
        desc: data['desc'] ?? '',
        userimg: data['userimg'] ?? '',
        location: LatLng(lat, lng),
    );
  }
}

class User {
  final String userid;
  final String name;
  final String image;
  final LatLng location;

  User({
    this.userid,
    this.name,
    this.image,
    this.location,
  });
  factory User.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;

    return User(
      userid: doc.documentID,
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      location: data['location'] ?? '',
    );
  }
}

class MarkerPopupModel
    extends ChangeNotifier {
  bool _visible = false;
  bool _tempHidden = false;
  Post _post;
  User _user;
  double _leftMargin;
  double _topMargin;

  void rebuild() {
    notifyListeners();
  }

  void updateUser(User user){
    _user = user;
  }
  void updatePost(Post post) {
    _post = post;
  }

  void updateVisibility(bool visible) {
    _visible = visible;
  }

  void updatePopup(
      BuildContext context,
      GoogleMapController controller,
      LatLng location,
      double popupWidth,
      double popupOffset,
      ) async {
    double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    ScreenCoordinate screenCoordinate =
    await controller.getScreenCoordinate(location);

    double left = (screenCoordinate.x.toDouble() / devicePixelRatio) -
        (popupWidth / 2);
    double top =
        (screenCoordinate.y.toDouble() / devicePixelRatio) - popupOffset;
    if (left < 0 || top < 0) {
      _tempHidden = true;
    } else {
      _tempHidden = false;
      _leftMargin = left;
      _topMargin = top;
    }
  }

  bool get showInfoWindow =>
      (_visible == true && _tempHidden == false) ? true : false;

  double get leftMargin => _leftMargin;

  double get topMargin => _topMargin;

  Post get post => _post;
  User get user => _user;
}