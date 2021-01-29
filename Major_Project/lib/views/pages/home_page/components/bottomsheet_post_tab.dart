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
import 'package:major_project/services/firebase/firebase_storage.dart';
import 'package:major_project/services/firebase/firestore_services.dart';
import 'package:provider/provider.dart';

class AddPostTab extends StatefulWidget {
  final User user;
  final LocationData location;
  final String address;

  AddPostTab({Key key, this.user, this.location, this.address})
      : super(key: key);

  @override
  _AddPostTabState createState() => _AddPostTabState();
}

class _AddPostTabState extends State<AddPostTab> {
  String _txt;
  String _imageURL;
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
            // post text area
            Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // circle avatar
                  Container(
                    padding: EdgeInsets.only(top: 10, right: 10),
                    child: CircleAvatar(
                        child: (widget.user.photoURL != null)
                            ? ClipOval(
                                child: CachedNetworkImage(
                                imageUrl: widget.user.photoURL,
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ))
                            : (widget.user.displayName != null &&
                                    widget.user.displayName != "")
                                ? Text(
                                    '${widget.user.displayName.characters.first.toUpperCase()}')
                                : Text("?")),
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // text box
                      Container(
                        padding: EdgeInsets.only(top: 8, right: 8, bottom: 4),
                        child: TextFormField(
                          // bigger to indicate more text is allowed
                          autofocus: true,
                          minLines: 3,
                          maxLines: 20,
                          autocorrect: false,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding: EdgeInsets.all(10),
                            hintText: FlutterI18n.translate(
                                context, "postpage.postmessage"),
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          onChanged: (String value) {
                            _txt = value;
                          },
                        ),
                      ),
                    ],
                  )),
                ]),
            // pic after adding it if not null
            if (_imageURL != null)
              CachedNetworkImage(
                imageUrl: _imageURL,
                errorWidget: (context, str, _) {
                  return Icon(Icons.error);
                },
              ),

            // location info and add pic
            Divider(),
            Row(
              children: [
                Container(
                    child: Icon(
                  Icons.location_on,
                )),
                Text(
                  (widget.address != null)
                      ? widget.address
                      : FlutterI18n.translate(context, "postpage.error"),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.image),
                  onPressed: () async {
                    var image = await pickImageFromGallery();
                    setState(() {
                      _imageURL = image;
                    });
                  },
                  color: Theme.of(context)
                      .primaryColor, //todo: popup for image or camera,
                )
              ],
            ),
            Divider(),
            // post button
            FlatButton(
              color: Theme.of(context).accentColor,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              child: Text(
                FlutterI18n.translate(context, "postpage.post"),
                // style: TextStyle(
                //   color: Theme.of(context).accentColor,
                // ),
              ),
              onPressed: () async {
                _db.addPost(
                    type: 'Post',
                    username: context.read<User>().displayName ?? "Anonymous",
                    body: _txt ?? '',
                    userImgURL: context.read<User>().photoURL ?? null,
                    postImgURL: _imageURL ?? null,
                    uid: context.read<User>().uid,
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
