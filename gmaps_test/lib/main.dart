import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gmaps_test/services/firebase_db.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:clippy_flutter/clippy_flutter.dart';
import 'services/notifications.dart';
import 'models/models.dart';
//source flutter_local_notifications 3.0.1+3  example
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'services/firebase_db.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject =
BehaviorSubject<String>();

const MethodChannel platform =
MethodChannel('dexterx.dev/flutter_local_notifications_example');

class ReceivedNotification {
  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });

  final int id;
  final String title;
  final String body;
  final String payload;
}
Future<void> _repeatNotification() async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails('repeating channel id',
      'repeating channel name', 'repeating description');
  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.periodicallyShow(1, 'title',
      'it\'s wednesday', RepeatInterval.everyMinute, platformChannelSpecifics,
      androidAllowWhileIdle: true);
}

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String timeZoneName = await platform.invokeMethod('getTimeZoneName');
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}
Future<void> main() async {
  //notifications init
  WidgetsFlutterBinding.ensureInitialized();
  final db = FirebaseService();
  print(db);



  final NotificationAppLaunchDetails notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('app_icon');

  /// Note: permissions aren't requested here just to demonstrate that can be
  /// done later
  final IOSInitializationSettings initializationSettingsIOS =
  IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {
        didReceiveLocalNotificationSubject.add(ReceivedNotification(
            id: id, title: title, body: body, payload: payload));
      });
  const MacOSInitializationSettings initializationSettingsMacOS =
  MacOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false);
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
        if (payload != null) {
          debugPrint('notification payload: $payload');
        }
        selectNotificationSubject.add(payload);
      });
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (context) => MarkerPopupModel()),
    StreamProvider<List<Post>>.value(
      value: db.streamPosts()),
  ],
    child: MyApp(),

  ),
  );
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CustomInfoWindow(),
    );
  }
}

class CustomInfoWindow extends StatefulWidget {
  @override
  _CustomInfoWindowState createState() => _CustomInfoWindowState();
}

class _CustomInfoWindowState extends State<CustomInfoWindow> {
  GoogleMapController mapController;
  BitmapDescriptor testuserIcon; //todo
  BitmapDescriptor messageicon;
  List<Post> posts;
  @override
  void initState() {
    super.initState();
    _repeatNotification();
    getBytesFromAsset('assets/bunny.jpg', 128).then((onValue) {
      testuserIcon =BitmapDescriptor.fromBytes(onValue);});
    getBytesFromAsset('assets/message.png', 128).then((onValue) {
      messageicon =BitmapDescriptor.fromBytes(onValue);});
    print(testuserIcon);
    print("is init running before");

  }
  //to bytestream
  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
  }
  //get curr state


  final LatLng _center = LatLng(43.897095, -78.865791);
  final double _zoom = 15.0;
  final Map<String, User> _testUsers = {
    'test': User(
      userid: "documentid",
      name: "Bunny",
      image: "https://via.placeholder.com/150",
      location: LatLng(43.897095, -78.865791),
    ),
  };
  final Map<String, Post> _testPosts = {
  /*  "p1": Post(
      postid:"docid",
      user:"bunny",
      desc:"test",
      userimg:"https://via.placeholder.com/150",
      location:LatLng(43.897095, -78.86225791),
    ),*/
  };

  final double _infoWindowWidth = 250;
  final double _popupOffset = 170;
  List<Marker> addMarkers(snaps, markersList) {
    for (int i = 0; i < snaps.length; ++i) {
      markersList.add(Marker(
        markerId: MarkerId(snaps[i]['venueName']),
        position: LatLng(snaps[i]['latN'], snaps[i]['longE']),
      ));
    }
  }

  Set<Marker> _markers = Set<Marker>();


  @override
  Widget build(BuildContext context) {
    final providerObject = Provider.of<MarkerPopupModel>(context, listen: false);
    final postsList = Provider.of<List<Post>>(context);
    print("postslist: ");
    print(postsList);

    if(postsList !=null) {
      postsList.forEach((v) =>
      {
        _markers.add(
            Marker(
              markerId: MarkerId(v.postid),
              position: v.location,
              icon: messageicon,

              onTap: () {
                providerObject.updatePopup(
                  context,
                  mapController,
                  v.location,
                  _infoWindowWidth,
                  _popupOffset,
                );
                providerObject.updatePost(v);
                providerObject.updateUser(null);
                providerObject.updateVisibility(true);
                providerObject.rebuild();
                print(providerObject);
              },
            )
        )});
    };
    print(_markers);
    _testPosts.forEach(
          (k, v) => _markers.add(
        Marker(
          markerId: MarkerId(v.postid),
          position: v.location,
          icon: messageicon,

          onTap: () {
            providerObject.updatePopup(
              context,
              mapController,
              v.location,
              _infoWindowWidth,
              _popupOffset,
            );
            providerObject.updatePost(v);
            providerObject.updateUser(null);
            providerObject.updateVisibility(true);
            providerObject.rebuild();
            print (providerObject);
          },
        ),
      ),
    );
    print(_markers);

    _testUsers.forEach(
          (k, v) => _markers.add(
        Marker(
          markerId: MarkerId(v.userid),
          position: v.location,
          icon: testuserIcon,

            onTap: () {
            providerObject.updatePopup(
              context,
              mapController,
              v.location,
              _infoWindowWidth,
              _popupOffset,
            );
            providerObject.updateUser(v);
            providerObject.updatePost(null);
            providerObject.updateVisibility(true);
            providerObject.rebuild();
            print (providerObject);
          },
        ),
      ),
    );
    print(_markers);

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
                    child: (providerObject.post == null && providerObject.user == null ||
                        !providerObject.showInfoWindow)
                        ? Container()
                        : Container(
                      margin: EdgeInsets.only(
                        left: providerObject.leftMargin,
                        top: providerObject.topMargin,
                      ),
                      //start popupmodel
                      child: (providerObject.user == null) ?
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
                            title: Text(providerObject.post.desc),
                            trailing: Icon(Icons.more_vert),
                          )

                      )
                      :Container(
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
                          title: Text(providerObject.user.name),
                          trailing: Icon(Icons.more_vert),
                        )

                        )
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
                if (providerObject.user != null) {
                  providerObject.updatePopup(
                    context,
                    mapController,
                    providerObject.user.location,
                    _infoWindowWidth,
                    _popupOffset,
                  );
                  providerObject.rebuild();
                }
              },
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
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