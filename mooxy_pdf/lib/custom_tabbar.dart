import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final hoverIndexProvider = StateProvider<int>((ref) {
  return -1;
});

class CustomTabBar extends ConsumerStatefulWidget {
  final TabController tabController;
  final PageController pageController;
  const CustomTabBar(
      {Key? key, required this.tabController, required this.pageController})
      : super(key: key);
  @override
  _CustomTabBarState createState() => _CustomTabBarState();
}

class _CustomTabBarState extends ConsumerState<CustomTabBar>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return TabBar(
      // indicator: BoxDecoration(
      //   color: Colors.grey.shade800,
      //   borderRadius: BorderRadius.circular(50),
      // ),
      labelPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      indicatorSize: TabBarIndicatorSize.tab,
      isScrollable: true,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      tabAlignment: TabAlignment.start,
      tabs: [
        'Direct Solutions',
        'Diode',
        'Schematic',
        'Layers',
        'Cpu Bit Map',
        'Special Schematic',
      ].asMap().entries.map((entry) {
        return MouseRegion(
          hitTestBehavior: HitTestBehavior.deferToChild,
          onHover: (event) {
            // log('Hovering');
            ref.read(hoverIndexProvider.notifier).state = entry.key;
            if (ref.read(hoverIndexProvider) != -1) {
              widget.tabController.animateTo(ref.read(hoverIndexProvider));
            } else {
              // widget.tabController.animateTo(widget.tabController.index);
            }
          },
          onExit: (event) {
            // setState(() {
            widget.tabController
                .animateTo(widget.pageController.page!.toInt().abs());
            // });
          },
          child: Tab(text: entry.value),
        );
      }).toList(),
      controller: widget.tabController,
      onTap: (index) {
        setState(() {
          widget.tabController.index = index;
          widget.pageController.animateToPage(index,
              duration: Duration(milliseconds: 300), curve: Curves.ease);
          // ref.read(hoverIndexProvider) = -1;
        });
      },
    );
  }
}
