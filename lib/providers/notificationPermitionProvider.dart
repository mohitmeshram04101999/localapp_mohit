import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final notificationPermissionProvider = StateNotifierProvider<NotificationPermissionNotifier,bool>((ref) {
  return NotificationPermissionNotifier(false);
});


class NotificationPermissionNotifier extends StateNotifier<bool>
{
  NotificationPermissionNotifier(super.state);

  final _notification = FlutterLocalNotificationsPlugin();
  final _fireBaseMessaging = FirebaseMessaging.instance;


  Future<void> getNotification(BuildContext context) async
  {
    var _b = await _fireBaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    Logger().e("Permission ${_b.authorizationStatus}");

    if(_b.authorizationStatus==AuthorizationStatus.authorized)
      {
        state = true;
      }
    else
      {
        await getNotification(context);
      }


  }

}