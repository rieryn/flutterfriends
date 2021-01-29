import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:location/location.dart';
import 'dart:async';

import 'package:major_project/services/firebase/firestore_services.dart';

//location stream and also periodically write location to firestore
// needs to run for the whole life of the app anyway, idk how else to do it
//don't want to use onLocationChanged because the interval setting doesn't work on ios
class LocationService {
  bool _hasPermission;
  LocationData currentLocation;
  Stream<LocationData> locationStream;
  StreamController<LocationData> streamController;
  LocationData _locationData;

  final _db = FirebaseService();
  User user;
  int counter = 0;
  final authStream = FirebaseAuth.instance.authStateChanges();
  init() async {
    getPermissions();
    locationStream = periodicLocation();
    await getCurrentLocation();
  }

  Stream<LocationData> periodicLocation() {
    StreamController<LocationData> _streamController;
    Timer timer;
    Future<void> tick(_) async {
      counter++; //number of ticks
      Location location = new Location();
      _locationData = await location.getLocation();
      if (currentLocation?.latitude != _locationData?.latitude ||
          currentLocation?.longitude != _locationData?.longitude) {
        currentLocation = _locationData;
        _streamController.add(_locationData);
        authStream.listen((snap) {
          if (snap != null && (counter % 60 == 0)) {
            _db.updateProfileLocation(uid: snap.uid, location: currentLocation);
            print("updated location");
          }
        });
      }
    }

    // void startTimer() async {
    //    print("initialize location stream");
    // tick(null);
    timer = Timer.periodic(Duration(seconds: 5), tick);
    //  }

    void stopTimer() {
      /* if (timer != null) {
        timer.cancel();
        timer = null;
        _streamController.close();
        print("stream closed???");
      }*/
    }

    _streamController = StreamController<LocationData>(
        //    onListen: startTimer,
        //     onPause: stopTimer,
        //    onResume: startTimer,
        //    onCancel: stopTimer
        );

    return _streamController.stream.distinct();
  }

  LocationService._privateConstructor();

  static final LocationService _instance =
      LocationService._privateConstructor();

  static LocationService get instance => _instance;

  /*Stream<LocationData> periodicLocation() async* {
    Stream<LocationData> stream;
    while(true){
      Timer.periodic(Duration(seconds: 60) , (Timer t) => getCurrentLocation());
      var result = await getCurrentLocation();
      yield result;
    }
  }*/

  void getPermissions() async {
    Location location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        _hasPermission = true;
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        _hasPermission = false;
        return;
      }
    }
    _hasPermission = true;
    return;
  }

  void getCurrentLocation() async {
    Location location = new Location();
    currentLocation = await location.getLocation();
  }
}
