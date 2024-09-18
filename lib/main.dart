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
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  AwesomeNotifications().initialize(
    // Your app icon
    'resource://drawable/ic_launcher',
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.white,
        importance: NotificationImportance.High,
      )
    ],
  );
  AwesomeNotifications().setListeners(
    onActionReceivedMethod: (receivedAction) async {
// If the app was terminated, initialize the app
      if (receivedAction.actionType == ActionType.SilentAction ||
          receivedAction.actionType == ActionType.SilentBackgroundAction) {
// Do something in the background
      } else {
// Handle the click and navigate to the blog detail page
      }
    },
  );

  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    // AwesomeNotifications().requestPermissionToSendNotifications();
  }
  FirebaseMessaging.instance
      .getInitialMessage()
      .then((RemoteMessage? message) {
    if (message != null) {
      Navigator.of( navigatorKey.currentContext!).pop();
      showbackgroundNotification(message);
    }
  });
  FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true,badge: true,sound: true);

  FirebaseMessaging.onBackgroundMessage(showbackgroundNotification);

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    await showbackgroundNotification(message);
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    await showbackgroundNotification(message);
  });
  FirebaseMessaging.instance.getToken().then((token) {
    print("tokenxssn: $token");
  });
  FirebaseMessaging.instance.requestPermission(
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
  runApp(const ProviderScope(child: main_app()));

}

@pragma('vm:entry-point')
Future<void> showbackgroundNotification(RemoteMessage message) async {
  if (message.data.isNotEmpty) {
    final blogId = message.data['blog_id'];
    if (blogId != null && blogId.isNotEmpty) {
      if (navigatorKey.currentContext != null) {
        Navigator.push(
          navigatorKey.currentContext!,
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
    }
  }
  String? imageUrl = message.data['image_url'];

  String? bigPicturePath;
  if (imageUrl != null && imageUrl.isNotEmpty) {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/notification_image.jpg';
      File file = File(filePath);
      file.writeAsBytesSync(response.bodyBytes);
      bigPicturePath = filePath;
    } catch (e) {
      print('Error downloading image: $e');
    }
  }
// Handle the creation of the notification UI
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 10,
      channelKey: 'basic_channel',
      title: message.data['title'],
      body: message.data['body'],
      bigPicture: bigPicturePath != null ? 'file://$bigPicturePath' : null,
      notificationLayout: bigPicturePath != null
          ? NotificationLayout.BigPicture
          : NotificationLayout.Default,
    ),
  );
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


  @override
  void initState() {
    getToken();
    //_initializeNotifications(); // Ensure this is called during startup

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

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print("New FCM Token: $newToken");
      print('deviceId${deviceId}');

      var url = Config.get_home;
      http.Response response = await http.post(Uri.parse(url), body: {
        'user_id':'${deviceId}',
        "token":newToken
      });
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

            inputDecorationTheme: InputDecorationTheme(
              helperStyle: TextStyle(color: Colors.black)
            )
          ),
          home: SplashScreen()
      );
  }

}

