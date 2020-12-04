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
  @override
  Widget build(BuildContext context) {
    final _db = FirebaseService();
    var _user = Provider.of<User>(context, listen: false);
    var _location = context.watch<LocationData>();
    print(_location.toString());
    bool loggedIn = _user != null;
    String _imageURL = 'http://placekitten.com/200/300';
    String _post;

    if(loggedIn){
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: MediaQuery.of(context).size.height*0.4,
      color: Color(0xFF737373),
      child: Container(
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.lightGreen,
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
                  borderSide: BorderSide(color: Colors.blueGrey),
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
              color: Colors.green[50],
              onPressed: () {
                print("adding at location: "+_location.toString());
                _db.addPost(
                      username: _user.displayName,
                      body: _post?? '',
                      userImgURL: _user.photoURL ?? 'http://placekitten.com/200/300',
                      postImgURL: _imageURL ?? 'http://placekitten.com/200/300',
                      uid: _user.uid,
                      location: LatLng(_location.latitude, _location.longitude) ?? LatLng(0,0));
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
      return AnimatedContainer(
        child: Container(
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.lightGreen[200],
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
                  color: Colors.greenAccent,
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
