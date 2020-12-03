import 'package:async/async.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:geocoding/geocoding.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:major_project/models/markerpopup_model.dart';
import 'package:major_project/models/post_model.dart';
import 'package:major_project/models/profile_model.dart';
import 'package:major_project/services/firestore_services.dart';
import 'package:major_project/services/marker_bitmapper.dart';
import 'package:major_project/services/localdb/covid_db.dart';
import 'package:major_project/services/utils.dart';
import 'package:major_project/views/components/profile_card.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import 'chat_page/chat_page.dart';
import 'home_page/home_page.dart';
//(0,0) is in ukraine just fyi
class MapPage extends StatefulWidget {
  MapPage({Key key}) : super(key: key);
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  String sessionId;
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  final _db = FirebaseService();
  final double _zoom = 5.0;
  LatLng _center = LatLng(43.897095, -78.865791);
  GoogleMapController mapController;
  BitmapDescriptor testuserIcon; //todo
  BitmapDescriptor messageicon;
  List<Post> posts;
  int _counter=0;

  @override
  void initState() {
    super.initState();
  }
  final Map<String, Profile> _testUsers = {
    'test': Profile(
      profileId: "documentid",
      username: 'bunny',
      profileImgURL: "https://via.placeholder.com/150",
      location: LatLng(43.897095, -78.865791),
    ),
  };
  final double _infoWindowWidth = 250;
  final double _popupOffset = 170;
  Set<Marker> _markers = Set<Marker>();
  List<Marker> addMarkers(snaps, markersList) {
    for (int i = 0; i < snaps.length; ++i) {
      markersList.add(Marker(
        markerId: MarkerId(snaps[i]['markerId']),
        position: LatLng(snaps[i]['latN'], snaps[i]['longE']),
      ));
    }
  }
  void setPostMarkers(BitmapDescriptor messageicon){
    final providerObject = Provider.of<MarkerPopupModel>(context, listen: false);
    final postsList = Provider.of<List<Post>>(context);
    if(postsList !=null) {
      _markers.clear();
      postsList.forEach((v) =>
      {
        _markers.add(
            Marker(
              markerId: MarkerId(v.postid),
              position: v.location,
              icon: MarkerBitmapper.instance.messageIcon,

              onTap: () {
                providerObject.updatePopup(
                  context,
                  mapController,
                  v.location,
                  _infoWindowWidth,
                  _popupOffset,
                );
                providerObject.updatePost(v);
                providerObject.updateProfile(null);
                providerObject.updateVisibility(true);
                providerObject.rebuild();
                print(providerObject);
              },
            )
        )});
    };
  }
  void setProfileMarkers(BitmapDescriptor userIcon){
    final providerObject = Provider.of<MarkerPopupModel>(context, listen: false);
    final profileList = Provider.of<List<Profile>>(context);
    if(profileList !=null) {
      _markers.clear();
      profileList.forEach((v) =>
      {
        _markers.add(
            Marker(
              markerId: MarkerId(v.profileId),
              position: v.location,
              icon: MarkerBitmapper.instance.messageIcon,

              onTap: () {
                providerObject.updatePopup(
                  context,
                  mapController,
                  v.location,
                  _infoWindowWidth,
                  _popupOffset,
                );
                providerObject.updatePost(null);
                providerObject.updateProfile(v);
                providerObject.updateVisibility(true);
                providerObject.rebuild();
                print(providerObject);
              },
            )
        )});
    };
  }
  Set<Circle> _circles = Set<Circle>();
  void _setCovidOverlay(List<List<Location>> locations, List<String> cases){
    //probably breaks if they're not same length? please refactor
    var whatever = zip([locations, cases]).toList();
    //looks something like  ( ([lat lng time], cases), ...)
    whatever.forEach((e) {
      _setCircle(LatLng(e.first[0].latitude, e.first[0].longitude), int.parse(e.last));
    });
  }
  void _setCircle(LatLng location, int cases){ //if i have to put markers or the whole widget thing to get labels again i might as well use markers
    final String circleid = 'circle_id_$_counter';
    if(cases <=0){return;}
    _counter++;

    _circles.add(Circle(
      circleId: CircleId(circleid),
      center: location,
      radius: log(cases)*2000,
      fillColor: Colors.red[600].withOpacity(0.5),
      strokeColor: Color(0x00000000),
    )
    );
    return;
  }

  @override
  Widget build(BuildContext context) {
    final providerObject = Provider.of<MarkerPopupModel>(context, listen: false);
    User user = Provider.of<User>(context,listen:false);
    setPostMarkers(testuserIcon);
    _setCovidOverlay(CovidDB.instance.tableCoordinates,CovidDB.instance.caseList);

    _testUsers.forEach(
          (k, v) => _markers.add(
        Marker(
          markerId: MarkerId(v.profileId),
          position: v.location,
          icon: MarkerBitmapper.instance.bunnyIcon,

          onTap: () {
            providerObject.updatePopup(
              context,
              mapController,
              v.location,
              _infoWindowWidth,
              _popupOffset,
            );
            providerObject.updateProfile(v);
            providerObject.updatePost(null);
            providerObject.updateVisibility(true);
            providerObject.rebuild();
            print (providerObject);
          },
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
        backgroundColor: Colors.blue,
      ),
      body: Container( //consume markers here
        child: Consumer<MarkerPopupModel>(
          builder: (context, model, child) {
            return Stack(
              children: <Widget>[
                child,
                Positioned(
                  left: 0,
                  top: 0,
                  child: Visibility(
                    visible: providerObject.showInfoWindow,
                    child: (providerObject.post == null && providerObject.profile == null ||
                        !providerObject.showInfoWindow)
                        ? Container()
                        : Container(
                        margin: EdgeInsets.only(
                          left: providerObject.leftMargin,
                          top: providerObject.topMargin,
                        ),
                        //start popupmodel
                        child: (providerObject.profile == null) ?
                        Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white,
                                  offset: Offset(1.0, 1.0),
                                ),
                              ],
                            ),
                            height: 100,
                            width: 250,
                            padding: EdgeInsets.all(15),
                            child: ListTile(
                              leading: FlutterLogo(),
                              title: Text(providerObject.post.body),
                              trailing: Icon(Icons.more_vert),
                            )

                        )
                            :Container(
                          height: 100,
                          width:250,
                          child: InkWell(child:ProfileCard( providerObject.profile),
                                onTap: () =>   {
                                  /*if (sessionId == null)
                                    {
                                      sessionId = await _db.guessChatSessionId(
                                          user.uid,
                                          providerObject.profile.profileId,
                                          user.photoURL,
                                          providerObject.profile.profileImgURL,
                                          user.displayName,
                                          providerObject.profile.username)
                                    },*/Navigator.pushNamed(context, '/chatPage'),
                                    print('clicked')
                                  }
                          ),
                        ),
                    ),
                  ),
                ),
              ],
            );
          },
          child: Positioned(
            child: GoogleMap(
              onTap: (position) {
                if (providerObject.showInfoWindow) {
                  providerObject.updateVisibility(false);
                  providerObject.rebuild();
                }
              },
              onCameraMove: (position) {
                if (providerObject.post != null) {
                  providerObject.updatePopup(
                    context,
                    mapController,
                    providerObject.post.location,
                    _infoWindowWidth,
                    _popupOffset,
                  );
                  providerObject.rebuild();
                }
                if (providerObject.profile != null) {
                  providerObject.updatePopup(
                    context,
                    mapController,
                    providerObject.profile.location,
                    _infoWindowWidth,
                    _popupOffset,
                  );
                  providerObject.rebuild();
                }
              },
              onMapCreated: (GoogleMapController controller) {
                setState(() {
                });
                mapController = controller;
              },
              circles: _circles,
              markers: _markers,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: _zoom,
              ),
            ),
          ),
        ),
      ),
    );
  }
}