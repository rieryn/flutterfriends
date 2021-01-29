import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:major_project/models/profile_model.dart';
import 'package:major_project/services/utils/location_service.dart';
import 'package:provider/provider.dart';

import 'bottomsheet_checkin_tab.dart';
import 'bottomsheet_post_tab.dart';

class AddPostBottomsheet extends StatefulWidget {
  @override
  _AddPostBottomsheetState createState() => _AddPostBottomsheetState();
}

class _AddPostBottomsheetState extends State<AddPostBottomsheet> {
  String _imageURL = null;
  String _txt;
  List<bool> isSelected = [true, false];
  int postTypeIndicator = 0;
  @override
  Widget build(BuildContext context) {
    var _user = Provider.of<User>(context, listen: false);

    LocationData _location = LocationService.instance.currentLocation;
    bool loggedIn = _user != null;

    Future<String> _address =
        get_addressName(_location.latitude, _location.longitude);

    if (loggedIn) {
      return FutureBuilder(
        initialData: "",
        future: get_addressName(_location.latitude, _location.longitude),
        builder: (context, snap) {
          return AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: MediaQuery.of(context).size.height,
              child: Container(
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ToggleButtons(
                            color: Colors.grey,
                            renderBorder: false,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            children: <Widget>[
                              Container(
                                  child: Text(FlutterI18n.translate(
                                      context, "postpage.post")),
                                  padding:
                                      EdgeInsets.only(left: 20, right: 20)),
                              Container(
                                child: Text(FlutterI18n.translate(
                                    context, "postpage.checkin")),
                                padding: EdgeInsets.only(left: 20, right: 20),
                              ),
                            ],
                            onPressed: (int index) {
                              setState(() {
                                if (index == 0) {
                                  isSelected = [true, false];
                                  postTypeIndicator = 0;
                                } else {
                                  isSelected = [false, true];
                                  postTypeIndicator = 1;
                                }
                              });
                            },
                            isSelected: isSelected,
                          ),
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      (postTypeIndicator == 0)
                          ? AddPostTab(
                              user: _user,
                              location: _location,
                              address: snap.data,
                            )
                          : AddCheckinTab(
                              user: _user,
                              location: _location,
                              address: snap.data,
                            ),
                    ],
                  )));
        },
      );
    } else {
      return AnimatedContainer(
          duration: Duration(milliseconds: 100),
          child: Container(
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(FlutterI18n.translate(context, "login.signinmessage")),
                OutlineButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  child: Text(
                    FlutterI18n.translate(context, "login.signin"),
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                ),
              ],
            ),
          ));
    }
  }

  Future<String> get_addressName(double lat, double lng) async {
    List<Placemark> plmks = await placemarkFromCoordinates(lat, lng);

    return plmks[0].name == plmks[0].subThoroughfare
        ? '${plmks[0].subThoroughfare} ${plmks[0].thoroughfare}'
        : plmks[0].name;
  }
}
