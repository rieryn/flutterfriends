import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notifications {
  final channelId = 'gpsNoti';
  final channelName = 'GPSNotification';
  final channelDescription = 'GPS Notification'

  var _flutterLocalNotificationsPlugins = FlutterLocalNotificationsPlugins();

  NotificationDetails _platformChannelInfo;
  var _notificationId = 100;
  void init(){
    var initSetAndr = AndroidInitializationSettings('mipmap/ic_launcher');
    var initSetIOS = IOSInitializationSettings(
      onDidReceiveLocalNotification: (int id, String title, String body, String payload){
      return null;
      },
    );
    var initSet = InitializationSettings(initSetAndr, initSetIOS);
    _flutterLocalNotificationsPlugins.initialize(initSet, onSelectNotification: onSelectNotification);

    void androidChannelInfo = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      ticker: 'ticker',
    );

    void iosChannelInfo = IOSNotificationDetails();

    _platformChannelInfo = NotificationDetails(
      android: androidChannelInfo,
      iOS: iosChannelInfo,
    );
  }
}
