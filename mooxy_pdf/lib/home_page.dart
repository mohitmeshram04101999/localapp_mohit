import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mooxy_pdf/bottomForm.dart';
import 'package:mooxy_pdf/component_search.dart';
import 'package:mooxy_pdf/custom_tabbar.dart';
import 'package:mooxy_pdf/flashFiles.dart';
import 'package:mooxy_pdf/flashFiles_controller.dart';
import 'package:mooxy_pdf/full_form.dart';
import 'package:mooxy_pdf/home_page_banners.dart';
import 'package:mooxy_pdf/left_section.dart';
import 'package:mooxy_pdf/login_page.dart';
import 'package:mooxy_pdf/providers.dart';
import 'package:mooxy_pdf/right_section.dart';

class RightPageKeyNotifier
    extends StateNotifier<GlobalKey<RightSectionState>?> {
  RightPageKeyNotifier() : super(null);

  // Method to set the GlobalKey
  void setKey(GlobalKey<RightSectionState> key) {
    state = key;
  }

  // Method to clear the GlobalKey
  void clearKey() {
    state = null;
  }
}

final rightPageKeyProvider =
    StateNotifierProvider<RightPageKeyNotifier, GlobalKey<RightSectionState>?>(
  (ref) => RightPageKeyNotifier(),
);

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  PageController? _pageController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _pageController = PageController(
      initialPage: 0,
      keepPage: true,
    );
    // Future.microtask(() {
    //   ref
    //       .read(rightPageKeyProvider.notifier)
    //       .setKey(GlobalKey<RightSectionState>());
    // });
    Future.delayed(
      Duration(milliseconds: 1000),
      () => showDialog(
        context: context,
        builder: (context) => Dialog(
            insetPadding: EdgeInsets.all(100),
            child: Stack(
              children: [
                Center(child: BottomForm()),
                Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.cancel))),
              ],
            )),
      ),
    );
  }

  getBanner() async {
    Dio dio = Dio();
    Response response = await dio.get(
        'https://api.mooxy.co.in/api/desktop/getBanners?type=desktopBanner');
    return response.data;
  }

  final childPageKey = GlobalKey<RightSectionState>();
  // performSearch() {
  //   if (mounted) {
  //     childPageKey.currentState?.performSearch([
  //       childPageKey.currentState!.firstPdfController,
  //       childPageKey.currentState!.splitPdfController,
  //       childPageKey.currentState!.thirdPdfController,
  //       childPageKey.currentState!.fourthPdfController,
  //     ]);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        appBar: AppBar(
          toolbarHeight: 70,
          flexibleSpace: FutureBuilder<dynamic>(
            future: getBanner(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData) {
                return Center(child: Text('No data available'));
              }
              final result = snapshot.data;
              return Image.network(
                  AppStateProviders.prifixUrl + result['data']['bannerImage'],
                  fit: BoxFit.cover);
            },
          ),
        ),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Column(
              children: [
                Container(
                  color: Colors.grey[900],
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ref.watch(isLeftSectionOpen)
                          ? CustomTabBar(
                              tabController: _tabController!,
                              pageController: _pageController!)
                          : Container(),
                      Spacer(),
                      if (ref.watch(currentPdfProvider) != null) ...{
                        if (ref
                            .watch(searchResult.notifier)
                            .state
                            .isNotEmpty) ...{
                          if (ref.watch(isFirstPdfActive)) ...{
                            Text(
                              "${ref.watch(searchResult.notifier).state[0].currentInstanceIndex} / ${ref.watch(searchResult.notifier).state[0].totalInstanceCount}",
                              style: const TextStyle(fontSize: 16),
                            )
                          },
                          if (ref.watch(isSecondPdfActive)) ...{
                            Text(
                              "${ref.watch(searchResult.notifier).state[1].currentInstanceIndex} / ${ref.watch(searchResult.notifier).state[1].totalInstanceCount}",
                              style: const TextStyle(fontSize: 16),
                            )
                          },
                          if (ref.watch(isThirdPdfActive)) ...{
                            Text(
                              "${ref.watch(searchResult.notifier).state[2].currentInstanceIndex} / ${ref.watch(searchResult.notifier).state[2].totalInstanceCount}",
                              style: const TextStyle(fontSize: 16),
                            )
                          },
                          if (ref.watch(isFourthPdfActive)) ...{
                            Text(
                              "${ref.watch(searchResult.notifier).state[3].currentInstanceIndex} / ${ref.watch(searchResult.notifier).state[3].totalInstanceCount}",
                              style: const TextStyle(fontSize: 16),
                            )
                          },
                        },
                        const SizedBox(
                          width: 10,
                        ),
                        // if (rightPageKey?.currentState != null) ...{
                        SizedBox(
                          width: 250,
                          height: 35,
                          child: SearchBar(
                            controller: childPageKey!
                                .currentState?.searchTextController,
                            hintText: 'Search text',
                            side: WidgetStatePropertyAll(
                                BorderSide(color: Colors.grey)),
                            onSubmitted: (value) {
                              // performSearch();
                              // childPageKey.cur     rentState?.performSearchFromParent();
                            },
                          ),
                        ),
                        // },
                        const SizedBox(
                          width: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Tooltip(
                            message: 'Previous',
                            child: SizedBox(
                              height: 35,
                              width: 35,
                              child: FittedBox(
                                child: IconButton.filledTonal(
                                  onPressed: () {
                                    if (ref
                                        .read(searchResult.notifier)
                                        .state
                                        .isNotEmpty) {
                                      if (ref.read(isFirstPdfActive)) {
                                        ref
                                            .read(searchResult.notifier)
                                            .state[0]
                                            .previousInstance();
                                      }
                                      if (ref.read(isSecondPdfActive)) {
                                        ref
                                            .read(searchResult.notifier)
                                            .state[1]
                                            .previousInstance();
                                      }
                                      if (ref.read(isThirdPdfActive)) {
                                        ref
                                            .read(searchResult.notifier)
                                            .state[2]
                                            .previousInstance();
                                      }
                                      if (ref.read(isFourthPdfActive)) {
                                        ref
                                            .read(searchResult.notifier)
                                            .state[3]
                                            .previousInstance();
                                      }
                                      // setState(() {});
                                    }
                                  },
                                  icon: const Icon(
                                      Icons.keyboard_arrow_left_rounded),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Tooltip(
                              message: 'Next',
                              child: SizedBox(
                                  height: 35,
                                  width: 35,
                                  child: FittedBox(
                                    child: IconButton.filledTonal(
                                      onPressed: () {
                                        if (ref
                                            .read(searchResult.notifier)
                                            .state
                                            .isNotEmpty) {
                                          if (ref.read(isFirstPdfActive)) {
                                            ref
                                                .read(searchResult.notifier)
                                                .state[0]
                                                .nextInstance();
                                          }
                                          if (ref.read(isSecondPdfActive)) {
                                            ref
                                                .read(searchResult.notifier)
                                                .state[1]
                                                .nextInstance();
                                          }
                                          if (ref.read(isThirdPdfActive)) {
                                            ref
                                                .read(searchResult.notifier)
                                                .state[2]
                                                .nextInstance();
                                          }
                                          if (ref.read(isFourthPdfActive)) {
                                            ref
                                                .read(searchResult.notifier)
                                                .state[3]
                                                .nextInstance();
                                          }
                                          //refresh the list of search results
                                          // ref.read(searchResult.notifier).state = [];
                                          // setState(() {});
                                        }
                                      },
                                      icon: const Icon(
                                          Icons.keyboard_arrow_right_rounded),
                                    ),
                                  )),
                            )),
                        const SizedBox(
                          width: 10,
                        ),
                        DropdownButton(
                          value: ref.watch(selectedSearchType),
                          items: [
                            const DropdownMenuItem(
                                child: Text('Perfect Search'), value: 1),
                            const DropdownMenuItem(
                                child: Text('Similar Search'), value: 2),
                          ],
                          onChanged: (value) {
                            ref.read(selectedSearchType.notifier).state =
                                value!;
                          },
                          underline: Container(),
                          borderRadius: BorderRadius.circular(5),
                          selectedItemBuilder: (context) {
                            return [
                              Center(
                                child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 5),
                                    decoration: BoxDecoration(
                                        color:
                                            Colors.deepPurple.withOpacity(0.5),
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    child: Text('Perfect Search')),
                              ),
                              Center(
                                child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 5),
                                    decoration: BoxDecoration(
                                        color:
                                            Colors.deepPurple.withOpacity(0.5),
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    child: Text('Similar Search')),
                              ),
                            ];
                          },
                        ),
                      },
                      InkWell(
                        onTap: () {},
                        child: Tooltip(
                          message: 'Pin abbreviation',
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                  height: 35,
                                  width: 35,
                                  child: FittedBox(
                                    child: IconButton.filledTonal(
                                      icon: const Text('PA'),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .push(CupertinoPageRoute(
                                          builder: (context) {
                                            return const FullFormSearch();
                                          },
                                        ));
                                      },
                                    ),
                                  ))),
                        ),
                      ),
                      Tooltip(
                        message: 'Chip compatibility search',
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                                height: 35,
                                width: 35,
                                child: FittedBox(
                                  child: IconButton.filledTonal(
                                    icon: const Text('CCS'),
                                    onPressed: () {
                                      Navigator.of(context)
                                          .push(CupertinoPageRoute(
                                        builder: (context) {
                                          return const ComponentSearch();
                                        },
                                      ));
                                    },
                                  ),
                                ))),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                              height: 35,
                              width: 35,
                              child: FittedBox(
                                  child: IconButton.filledTonal(
                                      onPressed: () {
                                        ref.read(isPanActive.notifier).state =
                                            !ref.read(isPanActive);
                                        // setState(() {});
                                      },
                                      icon: Icon(ref
                                                  .read(isPanActive.notifier)
                                                  .state ==
                                              true
                                          ? Icons.pan_tool
                                          : Icons.pan_tool_alt))))),
                      // Padding(
                      //     padding: const EdgeInsets.all(8.0),
                      //     child: SizedBox(
                      //         height: 35,
                      //         width: 35,
                      //         child: FittedBox(
                      //             child: IconButton.filledTonal(
                      //                 onPressed: () {
                      //                   ref
                      //                           .read(isBottomSectionActive
                      //                               .notifier)
                      //                           .state =
                      //                       !ref.read(isBottomSectionActive);
                      //                   setState(() {});
                      //                 },
                      //                 icon: const Text("DU"))))),
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Tooltip(
                            message: 'Flash Files',
                            child: SizedBox(
                                height: 35,
                                width: 35,
                                child: FittedBox(
                                  child: IconButton.filledTonal(
                                    onPressed: () {
                                      FlashFilesController()
                                          .getAllParentFlashFiles();
                                      Navigator.of(context)
                                          .push(CupertinoPageRoute(
                                        builder: (context) {
                                          return const FlashFiles();
                                        },
                                      ));
                                    },
                                    icon: const Icon(Icons.usb_rounded),
                                  ),
                                )),
                          )),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Tooltip(
                          message: 'Toggle Left Section',
                          child: SizedBox(
                            height: 35,
                            width: 35,
                            child: FittedBox(
                              child: IconButton.filledTonal(
                                  onPressed: () {
                                    ref.read(isLeftSectionOpen.notifier).state =
                                        !ref.read(isLeftSectionOpen);
                                  },
                                  icon: ref
                                              .read(isLeftSectionOpen.notifier)
                                              .state ==
                                          true
                                      ? Icon(Icons.cancel_outlined)
                                      : Icon(Icons.menu)),
                            ),
                          ),
                        ),
                      ),
                      Tooltip(
                        message: 'Logout',
                        child: SizedBox(
                          height: 35,
                          width: 35,
                          child: FittedBox(
                            child: IconButton.filledTonal(
                                onPressed: () {
                                  ref
                                      .read(sharedPreferencesProvider)
                                      .value!
                                      .clear();
                                  Navigator.pushReplacement(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) => LoginPage()));
                                },
                                icon: Icon(Icons.power_settings_new_rounded),
                                color: Colors.red),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth * 0.3),
                        child: LeftSection(
                            tabController: _tabController,
                            pageController: _pageController),
                      ),
                      Expanded(
                        child: ref.watch(currentPdfProvider) != null
                            ? RightSection(
                                key: childPageKey,
                              )
                            : Center(child: HomePageBanners()),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      // ),
      WindowTitleBarBox(
        child: Row(
          children: [
            Expanded(child: Center(child: MoveWindow())),
            Container(
              // width: 200,
              height: double.infinity,
              clipBehavior: Clip.hardEdge,
              padding: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                  // color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(150)),
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
                  )
                ],
              ),
            )
          ],
        ),
      )
    ]);
  }
}
