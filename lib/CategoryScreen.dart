import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:localapp/MoreScreen.dart';
import 'package:localapp/component/logiin%20dailog.dart';

import 'package:localapp/providers/location%20permission%20provider.dart';
import 'package:localapp/providers/notificationPermitionProvider.dart';
import 'package:localapp/providers/phoneNumberPerovider.dart';
import 'package:localapp/providers/profieleDataProvider.dart';
import 'package:logger/logger.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:flutter/material.dart';
import 'package:localapp/models/UserCategory.dart';
import 'CityScreen.dart';
import 'HomeScreen.dart';
import 'JobScreen.dart';
import 'MyPostScreen.dart';
import 'constants/Config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_notifications/awesome_notifications.dart';


class CategoryScreen extends ConsumerStatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> with WidgetsBindingObserver{
  int selectedIdx = -1;
  bool showShimmer = true; // Track whether to show shimmer or data
  final Duration shimmerDuration = const Duration(seconds: 2);
  String status = '';
  String bg_image = '';

  List user_category_data = [];
  List<User_Category_list> user_category_string = [];


  @override
  void didChangeAppLifecycleState(AppLifecycleState state)async{
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    logger.w(state);
    ref.read(locationPermmissionProvider.notifier).checkDialog(context);
    ref.read(notificationPermissionProvider.notifier).checkDialog(context);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  void selectItem(int index) {

    setState(() {
      if (index == 0) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomeScreen(
                    user_category_string[index].whatsappText,
                    user_category_string[index].whatsappNumber,
                    user_category_string[index].categoryId,
                    user_category_string[index].privacyType)));
      }
      if (index == 1) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => JobScreen()));
      }
      if (index == 2) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => CategoryScreen()));
      }
      if (index == selectedIdx) {
        // If the same item is tapped again, clear the selection
        selectedIdx = -1;
      } else {
        selectedIdx = index;
      }
    });
  }

  int _currentIndexBottom = 0;

  myInit() async {
    await ref
        .read(notificationPermissionProvider.notifier)
        .getNotification(context);
    await ref
        .read(locationPermmissionProvider.notifier)
        .getLocationPermmision(context);

    await ref.read(phoneNumberProvider.notifier).requestPermission();


    await ref.read(profileProvider.notifier).getUser(context);
    String? num = ref.read(phoneNumberProvider);
    print("Phone Num $num");

    ref.read(profileProvider.notifier).updateLocation(context);
  } // Track the current page index

  @override
  void initState() {

    WidgetsBinding.instance.addObserver(this);

    myInit();

    Timer(shimmerDuration, () {
      if (mounted) {
        setState(() {
          showShimmer = false;
        });
      }
    });
    Future.delayed(const Duration(milliseconds: 8), () {
      getUserCategory();
    });
    super.initState();
  }

  showLoaderDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      pageBuilder: (_, __, ___) {
        return Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              width: 80, // Dialog width
              height: 80, // Dialog height
              child: SingleChildScrollView(
                child: Image.asset(
                  "assets/images/loader.gif",
                  width: 80,
                  height: 80,
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  getUserCategory() async {
    showLoaderDialog(context);

    var url = Config.get_category;
    String? deviceId = await PlatformDeviceId.getDeviceId;

    http.Response response =
        await http.post(Uri.parse(url), body: {'user_id': deviceId});

    Logger().e('error Point ${response.body}');

    logger.i("${url} \n${response.statusCode} \n${jsonDecode(response.body)}");

    Map<String, dynamic> data = json.decode(response.body);
    status = data["success"];
    print('datadata${data}');

    Navigator.of(context).pop();

    if (status == "0") {
      user_category_data = data['data']['category'] as List;
      user_category_string = user_category_data
          .map<User_Category_list>((json) => User_Category_list.fromJson(json))
          .toList();

      print("pass");

      setState(() {
        bg_image = data['data']['bg_image'];
      });
      print('bg_image$bg_image');
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      floatingActionButton:kDebugMode? FloatingActionButton(
        onPressed: (){
          // ref.read(notificationPermissionProvider.notifier).getNotification(context);

         Timer(Duration(seconds: 3),(){
           AwesomeNotifications().createNotification(content: NotificationContent(
             id: 10,
             channelKey: "basic_channel",
             title:"data['title']",
             body: "data['body']",
             criticalAlert: true,
             wakeUpScreen: true,


           ));
         });

        },
      )

          :null,

      //Tag From BackGround
      backgroundColor: Colors.white,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(5.0), // here the desired height
          child: AppBar(
            backgroundColor:
                Colors.transparent, // Change app bar color to white
            automaticallyImplyLeading: false,
          )),

      body: WillPopScope(
        onWillPop: () async {
          exit(0);
        },
        child: RefreshIndicator(
            onRefresh: _refreshData,
            child: Stack(
              children: [
                Image.network(
                  '${Config.Image_Path}category/$bg_image',
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                  alignment: Alignment.center,
                ),
                SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //
                        //This is for checking any change in profile update;
                        if (kDebugMode)
                          Consumer(builder: (a, ref, c) {
                            var profile = ref.watch(profileProvider);
                            // var notification = ref.watch(notificationPermissionProvider);
                            // var phineNumber = ref.watch(phoneNumberProvider);

                            if (profile != null) {
                              return Padding(
                                padding: const EdgeInsets.all(40),
                                child: Card(
                                  color: Colors.grey.shade300,
                                  child: Column(
                                    children: [
                                      Text("Text"),
                                      Text(profile.name ?? ""),
                                      Text(profile.mobileNumber1 ?? ""),
                                      Text(profile.groupAccess ?? ""),
                                      ElevatedButton(
                                          onPressed: () {
                                            openLogInDialog(context);
                                          },
                                          child: const Text("Update")),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return const Text("No Profile Found ");
                          }),

                        const SizedBox(height: 120),
                        for (int i = 0;
                            i < user_category_string.length;
                            i++) ...[
                          //card That Showing That Page
                          GestureDetector(
                            onTap: () {


                              logger.e('wNuimber (${user_category_string[i].whatsappNumber})');

                              // insertLog(context, deviceId: ref.read(profileProvider)?.deviceId??"", id: user_category_string[i].categoryId, type: InsertLogType.category);

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomeScreen(
                                        user_category_string[i].whatsappText,
                                        user_category_string[i].whatsappNumber,
                                            user_category_string[i].categoryId,
                                            user_category_string[i].privacyType,
                                            subSubCategoryLabel: user_category_string[i].subSubCategoryLabel,
                                            privacyImage:
                                                user_category_string[i]
                                                    .privacyImage,
                                          )));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Center(
                                child: Container(
                                  child: showShimmer
                                      ? Shimmer.fromColors(
                                          baseColor: Colors.grey[300]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 10.0,
                                                horizontal: 20.0),
                                            padding: const EdgeInsets.all(10.0),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 50.0,
                                                  height: 50.0,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                ),
                                                const SizedBox(width: 10.0),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        width: double.infinity,
                                                        height: 12.0,
                                                        color: Colors.grey[300],
                                                      ),
                                                      const SizedBox(
                                                          height: 8.0),
                                                      Container(
                                                        width: double.infinity,
                                                        height: 12.0,
                                                        color: Colors.grey[300],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Column(
                                          children: [
                                            CachedNetworkImage(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                imageUrl:
                                                    '${Config.Image_Path + 'category/' + user_category_string[i].categoryImage}',
                                                placeholder: (context, url) =>
                                                    Image.asset(
                                                      "assets/images/loader.gif",
                                                      width: 80,
                                                      height: 80,
                                                    ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Image.asset(
                                                          "assets/images/loader.gif",
                                                          width: 80,
                                                          height: 80,
                                                        )),
                                            if(kDebugMode)
                                            Text(
                                                "p ${user_category_string[i].privacyType}  ${user_category_string[i].categoryId}")
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                      ],
                    ))
              ],
            )),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndexBottom,
        onTap: (int index) {
          setState(() {
            _currentIndexBottom = index;
            if (_currentIndexBottom == 0) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CategoryScreen()));
            }
            if (_currentIndexBottom == 1) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CityScreen()));
            }

            if (_currentIndexBottom == 2) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MyPostScreen(false)));
            }
            if (_currentIndexBottom == 3) {
              // showCustomPopup(context,'','','','');
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MoreScreen()));
            }
          });
        },
        selectedItemColor: Colors.blue, // Set the selected item color to white
        unselectedItemColor: Colors.black,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign),
            label: "What's New",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.post_add_outlined),
            label: 'My Posts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.widgets),
            label: 'More',
          ),
        ],
      ),
    );
  }

  Future _refreshData() async {
    Future.delayed(const Duration(milliseconds: 8), () {
      getUserCategory();
    });
  }
}
