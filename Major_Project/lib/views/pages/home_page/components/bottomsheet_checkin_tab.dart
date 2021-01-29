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
import 'package:major_project/services/firebase/firestore_services.dart';
import 'package:provider/provider.dart';

class AddCheckinTab extends StatefulWidget {
  final User user;
  final LocationData location;
  final String address;

  AddCheckinTab({Key key, this.user, this.location, this.address})
      : super(key: key);

  @override
  _AddCheckinTabState createState() => _AddCheckinTabState();
}

class _AddCheckinTabState extends State<AddCheckinTab> {
  String _txt;
  String _imageURL = null;
  final _db = FirebaseService();
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: Column(
          children: [
            Divider(),
            Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // main area
                  Container(
                    // avatar
                    padding: EdgeInsets.only(right: 10),
                    child: CircleAvatar(
                        child: widget.user.photoURL != null
                            ? ClipOval(
                                child: CachedNetworkImage(
                                imageUrl: widget.user.photoURL,
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ))
                            : widget.user.displayName != null &&
                                    widget.user.displayName != ""
                                ? Text(
                                    '${widget.user.displayName.characters.first.toUpperCase()}')
                                : Text("X")),
                  ),
                  Text(
                    widget.user.displayName != ""
                        ? ('${widget.user.displayName}')
                        : ('${widget.user.uid}'), //why
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ]),
            Divider(),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  padding: EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      Text(FlutterI18n.translate(context, "postpage.checkinto"),
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(
                          '${(widget.address != null) ? widget.address : 'error'}',
                          style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.primaryVariant,
                              fontSize: 20,
                              fontWeight: FontWeight.bold))
                    ],
                  )),
              TextFormField(
                // bigger to indicate more text is allowed
                autofocus: true,
                minLines: 1,
                maxLines: 2,
                autocorrect: false,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.all(10),
                  hintText:
                      FlutterI18n.translate(context, "postpage.checkinmessage"),
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onChanged: (String value) {
                  _txt = value;
                },
              ),
            ]),
            Divider(),
            FlatButton(
              color: Theme.of(context).accentColor,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              child: Text(
                FlutterI18n.translate(context, "postpage.checkin"),
                // style: TextStyle(
                //   color: Theme.of(context).accentColor,
                // ),
              ),
              onPressed: () async {
                _db.addPost(
                    type: 'Checkin',
                    username: widget.user.displayName,
                    body: _txt ?? '',
                    userImgURL: widget.user.photoURL ?? null,
                    postImgURL: _imageURL ?? null,
                    uid: widget.user.uid,
                    location: LatLng(widget.location.latitude,
                            widget.location.longitude) ??
                        LatLng(0, 0),
                    address: widget.address);
                Navigator.pop(context);
                Scaffold.of(context).showSnackBar(SnackBar(
                  duration: Duration(seconds: 2),
                  content: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(FlutterI18n.translate(context, "postpage.posted"))
                      ]),
                ));
              },
            ),
          ],
        ));
  }
}
