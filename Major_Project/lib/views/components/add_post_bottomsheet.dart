import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:major_project/models/profile_model.dart';
import 'package:major_project/services/firestore_services.dart';
import 'package:provider/provider.dart';

class AddPostBottomsheet extends StatelessWidget {
  Future<LocationData> getLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }
    _locationData = await location.getLocation();
    return _locationData;
  }
  @override
  Widget build(BuildContext context) {
    final _db = FirebaseService();
    var _user = Provider.of<User>(context, listen: false);
    bool loggedIn = _user != null;
    String _imageURL = 'http://placekitten.com/200/300';
    String _post;

    if(loggedIn){
    return Container(
      color: Color(0xFF737373),
      child: Container(
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: Row(
          children: <Widget>[
            ClipOval(
              child: CachedNetworkImage(
                imageUrl: _imageURL,
                placeholder: (context, url) => Image.asset('assets/bunny.jpg'),
                errorWidget: (context, url, error) => Icon(Icons.error),
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(child:Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Check In",
                    hintText: 'What are you up to?',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                // border animates when in focus
                // looks good!
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(1.0)),
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
              ),
              autocorrect: true,
              autofocus: true,
              textAlign: TextAlign.center,
              onChanged: (value) {_post = value;},
            ),
            OutlineButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              child: Text(
                'Post',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              color: Colors.blue,
              onPressed: () {
                getLocation().then((value)
                {
                  _db.addPost(
                      username: _user.displayName,
                      body: _post?? '',
                      userImgURL: _user.photoURL ?? 'http://placekitten.com/200/300',
                      postImgURL: _imageURL ?? 'http://placekitten.com/200/300',
                      uid: _user.uid,
                      location: LatLng(value.latitude, value.latitude) ?? LatLng(0,0));
                }
                );
                Navigator.pop(context);
              },
            ),
          ],
          )),
          ]
        )
      ),
    );
    }
    else{
      return Container(
        child: Container(
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                    "Sign in or create an account to continue"
                ),
                OutlineButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  child: Text(
                    'Sign in',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  color: Colors.blue,
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                ),
              ],
            ),
        )
      );
    }
  }
}
