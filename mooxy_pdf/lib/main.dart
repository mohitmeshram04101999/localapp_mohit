import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mooxy_pdf/home_page.dart';
import 'package:mooxy_pdf/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  runApp(const ProviderScope(child: MyApp()));
  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(1200, 800);
    win.minSize = initialSize;
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.title = "Mooxy";
    win.show();
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isEmailExists = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadEmail();
  }

  loadEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var email = prefs.getString('email');
    setState(() {
      if (email != null) {
        isEmailExists = true;
      }
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          dialogTheme: DialogTheme(
            backgroundColor: Colors.grey[900],
            titleTextStyle: TextStyle(color: Colors.white),
            contentTextStyle: TextStyle(color: Colors.white),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.grey[800]),
            padding: WidgetStatePropertyAll(
                EdgeInsets.symmetric(vertical: 20, horizontal: 30)),
          )),
          tabBarTheme: TabBarTheme(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            dividerHeight: 0,
            dividerColor: Colors.transparent,
            // labelPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.withOpacity(0.5), Colors.red],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          expansionTileTheme: ExpansionTileThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            childrenPadding: EdgeInsets.only(left: 20, bottom: 10, top: 10),
            collapsedBackgroundColor: Colors.black,

            // backgroundColor: Colors.grey[900],
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          checkboxTheme: CheckboxThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          )),
      home: AppLayout(
        child: Stack(
          children: [
            isEmailExists ? HomePage() : LoginPage(),
            // WindowTitleBarBox(
            //   child: Row(
            //     children: [
            //       Expanded(child: MoveWindow()),
            //       Container(
            //         // width: 200,
            //         height: double.infinity,
            //         clipBehavior: Clip.hardEdge,
            //         padding: EdgeInsets.symmetric(horizontal: 8),
            //         decoration: BoxDecoration(
            //             // color: Colors.grey[900],
            //             borderRadius: BorderRadius.circular(150)),
            //         child: Row(
            //           children: [
            //             MinimizeWindowButton(
            //               colors: WindowButtonColors(
            //                 iconNormal: Colors.white,
            //                 mouseOver: Colors.orangeAccent,
            //                 mouseDown: Colors.orange,
            //               ),
            //             ),
            //             MaximizeWindowButton(
            //               colors: WindowButtonColors(
            //                 iconNormal: Colors.white,
            //                 mouseOver: Colors.yellowAccent,
            //                 mouseDown: Colors.yellow,
            //               ),
            //             ),
            //             CloseWindowButton(
            //               colors: WindowButtonColors(
            //                 iconNormal: Colors.red,
            //                 mouseOver: Colors.redAccent,
            //                 mouseDown: Colors.red,
            //               ),
            //             )
            //           ],
            //         ),
            //       )
            //     ],
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}

class AppLayout extends StatelessWidget {
  final Widget child;

  const AppLayout({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: WindowTitleBarBox(
            child: Row(
              children: [
                Expanded(child: MoveWindow()),
                Container(
                  height: double.infinity,
                  clipBehavior: Clip.hardEdge,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(150),
                  ),
                  child: Row(
                    children: [
                      MinimizeWindowButton(
                        colors: WindowButtonColors(
                          iconNormal: Colors.white,
                          mouseOver: Colors.orangeAccent,
                          mouseDown: Colors.orange,
                        ),
                      ),
                      MaximizeWindowButton(
                        colors: WindowButtonColors(
                          iconNormal: Colors.white,
                          mouseOver: Colors.yellowAccent,
                          mouseDown: Colors.yellow,
                        ),
                      ),
                      CloseWindowButton(
                        colors: WindowButtonColors(
                          iconNormal: Colors.red,
                          mouseOver: Colors.redAccent,
                          mouseDown: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
