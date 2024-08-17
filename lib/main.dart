import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:localapp/SplashScreen.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:path_provider/path_provider.dart';
import 'BlogDetail.dart';
import 'constants/Config.dart';
import 'constants/prefs_file.dart';
import 'package:image/image.dart' as img;

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true,badge: true,sound: true);


  FirebaseMessaging.onBackgroundMessage(showbackgroundNotification);

//  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    await showbackgroundNotification(message);
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    await showbackgroundNotification(message);
  });
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
 SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark));
  runApp(const main_app());

}

Future<void> showbackgroundNotification(RemoteMessage message) async {

  print('clicking notification${message.notification!.title}');
  if (message.data.isNotEmpty) {
    final blogId = message.data['blog_id'];
    if(blogId!=''){
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => BlogDetailScreen(
            blogId,
            'Notification',
            '', // Pass other parameters as needed
            false,
          ),
        ),
      );

    }

    print('Blog ID: $blogId'); // Log the blog_id for debugging
  } else {
    print('No data payload received');
  }  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails('yourid', 'yourname',
      channelDescription: 'yourdescription',
      importance: Importance.max,
      priority: Priority.high,
      icon: "@mipmap/ic_launcher", //<-- Add this parameter
      ticker: 'ticker');
  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
      0, message.notification!.title, message.notification!.body, platformChannelSpecifics,
      payload: 'item x');
  //showPopup(message);
}
Future<bool> showPopup(RemoteMessage message) async {
  return await showDialog(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            height: 220,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message.notification!.title!,
                  style: TextStyle(fontWeight: FontWeight.bold,fontSize: 28),
                ),
                Divider(),
                Text(message.notification!.body!,
                  style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),
                ),
                SizedBox(height: 80,),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("Ok"),
                        style: ElevatedButton.styleFrom(
                            primary: Colors.red.shade800),
                      ),
                    ),

                  ],
                )

              ],
            ),
          ),
        );
      });
}


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
class main_app extends StatefulWidget {
  const main_app({Key? key}) : super(key: key);

  @override
  _main_appState createState() => _main_appState();
}

class _main_appState extends State<main_app> {
  Prefs prefs = new Prefs();


  String? version = '';
  String? storeVersion = '';
  String? storeUrl = '';
  String? packageName = '';

  Future showNotification(RemoteMessage message) async {
    print('clicking notification ${message.notification?.title}');

    String? imageUrl = message.notification?.android?.imageUrl;

    BigPictureStyleInformation bigPictureStyleInformation;

    if (imageUrl != null) {
      bigPictureStyleInformation = BigPictureStyleInformation(
        FilePathAndroidBitmap(imageUrl),
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        contentTitle: message.notification?.title,
        summaryText: message.notification?.body,
      );
    } else {
      bigPictureStyleInformation = BigPictureStyleInformation(
        DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        contentTitle: message.notification?.title,
        summaryText: message.notification?.body,
      );
    }

    AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'channel_1',
      'channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: bigPictureStyleInformation,
      ticker: 'ticker',
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  @override
  void initState() {
    getToken();
    super.initState();


  }

  late String token;
  getToken() async {
    token = (await FirebaseMessaging.instance.getToken())!;
    print('fcm_token${token}');
   // prefs.set_fcm_token(token);

    String user_id=await prefs.ismember_id();
    print('token_home${token}');
    String? deviceId = await PlatformDeviceId.getDeviceId;

    print('deviceId${deviceId}');

    var url = Config.get_home;
    http.Response response = await http.post(Uri.parse(url), body: {
      'user_id':'${deviceId}',
      "token":token
    });

    logger.i("$url \n${response?.statusCode} \n${jsonDecode(response.body??"")}");

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print("New FCM Token: $newToken");
      print('deviceId${deviceId}');

      http.Response response = await http.post(Uri.parse(url), body: {
        'user_id':'${deviceId}',
        "token":newToken
      });

      logger.i("$url \n${response?.statusCode} \n${jsonDecode(response?.body??"")}");

    });

  }
  @override
  Widget build(BuildContext context) {
    return

      MaterialApp(
        title: 'Local App',
          navigatorKey: navigatorKey, // Set the navigator key

          theme: ThemeData(

          primarySwatch: Colors.blue,
        ),
        home: SplashScreen()
    );
  }

}

