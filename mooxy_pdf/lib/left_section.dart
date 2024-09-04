import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mooxy_pdf/cpu_bin_map_tabbar.dart';
import 'package:mooxy_pdf/diode_controller.dart';
import 'package:mooxy_pdf/diode_tabbar.dart';
import 'package:mooxy_pdf/direct_solutions_tabbar.dart';
import 'package:mooxy_pdf/layer_tabbar.dart';
import 'package:mooxy_pdf/schematic_layer_tabbar.dart';
import 'package:mooxy_pdf/special_schematic_tabbar.dart';

StateProvider<bool> isLeftSectionOpen = StateProvider(
  (ref) => true,
);
final pdfFilesProvider =
    StateNotifierProvider<PdfFilesNotifier, List<PdfFile>>((ref) {
  return PdfFilesNotifier();
});

class PdfFilesNotifier extends StateNotifier<List<PdfFile>> {
  PdfFilesNotifier() : super([]);

  void addPdfFile(PdfFile file) {
    state = [...state, file]; // Create a new list instance
  }

  void removePdfFile(PdfFile file) {
    state.removeWhere(
      (element) {
        return element.pdfId == file.pdfId;
      },
    );
  }
}

class LeftSection extends ConsumerStatefulWidget {
  final TabController? tabController;
  final PageController? pageController;
  const LeftSection(
      {super.key, required this.tabController, required this.pageController});

  @override
  ConsumerState createState() => _LeftSectionState();
}

class _LeftSectionState extends ConsumerState<LeftSection>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Container(
      // height: MediaQuery.sizeOf(context).height,
      color: Colors.grey[900],
      width: ref.watch(isLeftSectionOpen) == true ? 300 : 50,
      child: ref.watch(isLeftSectionOpen) == true
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: PageView(
                    physics: NeverScrollableScrollPhysics(),
                    pageSnapping: true,
                    children: [
                      DirectSolutionsTabBar(),
                      DiodeTabBar(),
                      SchematicLayerTabBar(),
                      LayerTabBar(),
                      CpuBinMapTabBar(),
                      SpecialSchematicTabBar()
                    ],
                    controller: widget.pageController,
                  ),
                )
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          ref.read(isLeftSectionOpen.notifier).state =
                              !ref.read(isLeftSectionOpen);
                        },
                        icon: Icon(Icons.cancel_outlined))
                  ],
                ),
              ],
            ),
    );
  }
}
