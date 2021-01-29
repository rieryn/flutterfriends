import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:major_project/models/post_model.dart';
import 'package:major_project/models/profile_model.dart';

//covers the marker infowindow box
class MarkerPopupModel
    extends ChangeNotifier {
  bool _visible = false;
  bool _tempHidden = false;
  Post _post;
  Profile _profile;
  double _leftMargin;
  double _topMargin;

  void rebuild() {
    notifyListeners();
  }

  void updateProfile(Profile profile){
    _profile = profile;
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
  Profile get profile => _profile;
}