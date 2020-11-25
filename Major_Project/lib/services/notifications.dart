import 'dart:io' show Platform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notifications {
  final channelId = 'gpsNoti';
  final channelName = 'GPSNotification';
  final channelDescription = 'GPS Notification';

  var _flutterLocalNotificationsPlugins = FlutterLocalNotificationsPlugin();

  NotificationDetails _platformChannelInfo;
  var _notificationId = 100;
  void init() {
    var initSetAndr = AndroidInitializationSettings('mipmap/ic_launcher');
    var initSetIOS = IOSInitializationSettings(
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) {
        return null;
      },
    );
    var initSet = InitializationSettings(android: initSetAndr, iOS: initSetIOS);
    _flutterLocalNotificationsPlugins.initialize(initSet,
        onSelectNotification: onSelectNotification);

    var androidChannelInfo = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      ticker: 'ticker',
    );

    var iosChannelInfo = IOSNotificationDetails();

    _platformChannelInfo = NotificationDetails(
      android: androidChannelInfo,
      iOS: iosChannelInfo,
    );
  }

  Future onSelectNotification(var payload) async {
    if (payload != null) {
      print("onSelectNotification::payload = $payload");
    }
  }

  sendNotificationNow(String title, String body) {
    _flutterLocalNotificationsPlugins.show(
      _notificationId++,
      title,
      body,
      _platformChannelInfo,
    );
  }

  Future<List<PendingNotificationRequest>>
      getPendingNotificationRequests() async {
    return _flutterLocalNotificationsPlugins.pendingNotificationRequests();
  }
}
