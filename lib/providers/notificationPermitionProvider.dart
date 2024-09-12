import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:riverpod/riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:app_settings/app_settings.dart';

final notificationPermissionProvider = StateNotifierProvider<NotificationPermissionNotifier,bool>((ref) {
  return NotificationPermissionNotifier(false);
});


class NotificationPermissionNotifier extends StateNotifier<bool>
{
  NotificationPermissionNotifier(super.state);

  final _fireBaseMessaging = FirebaseMessaging.instance;


  Future<void> getNotification(BuildContext context) async
  {
    var b = await _fireBaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    Logger().e("Permission ${b.authorizationStatus}");

    if(b.authorizationStatus==AuthorizationStatus.authorized)
      {
        state = true;
      }
    else
      {
        await showDialog(context: context,barrierDismissible: false, builder: (context)=>AlertDialog(
          content: Column(mainAxisSize: MainAxisSize.min,children: [
            Icon(Icons.notifications,size: 40,),
            Text("Plese provide Notification permission  provide ${b.authorizationStatus==AuthorizationStatus.denied?'Frome Settings':''}",textAlign: TextAlign.center,),
            if(b.authorizationStatus==AuthorizationStatus.denied)
              ElevatedButton(onPressed: ()async{
                 AppSettings.openAppSettings(type: AppSettingsType.notification);
                 Logger().e("Permission Asked");
              }, child: const Text('Open Settings'))
          ],),
        ));
        await getNotification(context);
      }


  }

}