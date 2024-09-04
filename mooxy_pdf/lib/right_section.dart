import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mooxy_pdf/customCheckbox.dart';
import 'package:mooxy_pdf/diode_controller.dart';
import 'package:mooxy_pdf/file_model.dart';
import 'package:mooxy_pdf/left_section.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

final currentPdfProvider = StateProvider<PdfFile?>((ref) {
  return null;
});
final splitPdfProvider = StateProvider<PdfFile?>((ref) {
  return null;
});
final thirdPdfProvider = StateProvider<PdfFile?>((ref) {
  return null;
});
final fourthPdfProvider = StateProvider<PdfFile?>((ref) {
  return null;
});

final isFirstPdfActive = StateProvider<bool>((ref) {
  return false;
});
final isSecondPdfActive = StateProvider<bool>((ref) {
  return false;
});
final isThirdPdfActive = StateProvider<bool>((ref) {
  return false;
});
final isFourthPdfActive = StateProvider<bool>((ref) {
  return false;
});
final isBottomSectionActive = StateProvider<bool>((ref) {
  return false;
});

final isPanActive = StateProvider<bool>((ref) {
  return false;
});

final searchResult = StateProvider<List<PdfTextSearchResult>>((ref) {
  return [];
});

final selectedSearchType = StateProvider<int>((ref) {
  return 2;
});

final isComparingProvider = StateProvider<bool>((ref) {
  return false;
});

final selectedPdfIdProvider = StateProvider<String>((ref) {
  return '';
});

final selectedPdfControllerProvider =
    StateProvider<PdfViewerController?>((ref) {
  return null;
});

final selectedIndexProvider = StateProvider<int>((ref) {
  return 0;
});

final isFirstWidgetRenderedProvider = StateProvider<bool>((ref) {
  return false;
});

final isSecondWidgetRenderedProvider = StateProvider<bool>((ref) {
  return false;
});

final selectedPdfFilesProvider =
    StateNotifierProvider<PdfFilesSelectionNotifier, List<PdfFile>>((ref) {
  return PdfFilesSelectionNotifier();
});

class PdfFilesSelectionNotifier extends StateNotifier<List<PdfFile>> {
  PdfFilesSelectionNotifier() : super([]);

  void addPdfFile(PdfFile file) {
    state = [...state, file];
  }

  void removePdfFile(PdfFile file) {
    state = state.where((element) => element.pdfId != file.pdfId).toList();
  }

  removeController(int index) {
    state = List.from(state)..removeAt(index);
  }
}

final tempFileProvider =
    StateNotifierProvider<TempFileNotifier, List<FileModel>>((ref) {
  return TempFileNotifier();
});

class TempFileNotifier extends StateNotifier<List<FileModel>> {
  TempFileNotifier() : super([]);

  void add(FileModel file) {
    state = [
      ...state.where((existingFile) => existingFile.key != file.key),
      file
    ];
  }

  void remove(String key) async {
    state = state.where((existingFile) => existingFile.key != key).toList();
    try {
      final fileInfo = await DefaultCacheManager().getFileFromCache(key);
      if (fileInfo != null) {
        final file = fileInfo.file;
        if (await file.exists()) {
          await file.delete();
          await DefaultCacheManager().removeFile(key);
        }
      }
    } catch (e) {
      print("Error deleting file from device storage: $e");
    }
  }
}

final pdfWidgetsProvider =
    StateNotifierProvider<PdfWidgetsNotifier, List<Widget>>((ref) {
  return PdfWidgetsNotifier();
});

class PdfWidgetsNotifier extends StateNotifier<List<Widget>> {
  PdfWidgetsNotifier() : super([]);

  void addWidget(Widget widget) {
    state = [...state, widget];
  }

  void removeWidget(int index) {
    state = List.from(state)..removeAt(index);
  }
}

final pdfControllersProvider =
    StateNotifierProvider<PdfControllerNotifier, List<PdfViewerController>>(
        (ref) {
  return PdfControllerNotifier();
});

class PdfControllerNotifier extends StateNotifier<List<PdfViewerController>> {
  PdfControllerNotifier() : super([]);

  void addController(PdfViewerController controller) {
    state = [...state, controller];
  }

  void removeController(int index) {
    state = List.from(state)..removeAt(index);
    if (index == 0) {}
  }

  void initControllers(int count) {
    state = List.generate(count, (_) => PdfViewerController());
  }
}

class RightSection extends ConsumerStatefulWidget {
  const RightSection({super.key});

  @override
  ConsumerState createState() => RightSectionState();
}

class RightSectionState extends ConsumerState<RightSection> {
  final GlobalKey<SfPdfViewerState> _firstPdfViewerKey = GlobalKey();
  final GlobalKey<SfPdfViewerState> _secondPdfViewerKey = GlobalKey();
  final GlobalKey<SfPdfViewerState> _thirdPdfViewerKey = GlobalKey();
  final GlobalKey<SfPdfViewerState> _fourthPdfViewerKey = GlobalKey();
  final PdfViewerController firstPdfController = PdfViewerController();
  final PdfViewerController splitPdfController = PdfViewerController();
  final PdfViewerController thirdPdfController = PdfViewerController();
  final PdfViewerController fourthPdfController = PdfViewerController();
  final TextEditingController searchTextController = TextEditingController();
  dynamic currentPdf;
  FileInfo? _fileInfo;
  bool _isLoading = true;
  Timer? _searchTimer;
  String searchText = '';
  bool isSearched = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentPdf = ref.read(pdfFilesProvider).first;
    // initKey();
  }

  // Future<void> _loadFile() async {
  //   final fileInfo = await DefaultCacheManager().getFileFromCache(widget.pdfId);
  //   if (fileInfo != null) {
  //     setState(() {
  //       _fileInfo = fileInfo;
  //       _isLoading = false;
  //     });
  //   } else {
  //     // Optionally load from network if not cached
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  void initKey() async {
    ref.read(isFirstPdfActive.notifier).state = true;
    ref.read(isSecondPdfActive.notifier).state = false;
    ref.read(isThirdPdfActive.notifier).state = false;
    ref.read(isFourthPdfActive.notifier).state = false;
  }
  // List<PdfTextSearchResult>? ref.read(searchResult.notifier).state;
  // List<PdfTextSearchResult> ref.read(searchResult.notifier).state = [];

  void performSearch(List<PdfViewerController> pdfs) {
    // searchText = '';
    // setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // if (!mounted) return;
      if (mounted) {
        // setState(() {
        //   ref.read(searchResult.notifier).state.clear(); // Clear previous results
        // });
        log(ref.read(pdfControllersProvider).length.toString() +
            ' Length of PDF Controllers');
        // if (ref.read(pdfControllersProvider).length >= 2) {
        // if (ref.read(selectedSearchType.notifier).state == 1) {
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //   content: Text('Searching for ${searchTextController.text.trim()}'),
        // ));
        if (ref.read(selectedPdfFilesProvider).length >= 1) {
          for (PdfViewerController pdf in ref.read(pdfControllersProvider)) {
            if (pdf.pageCount > 0) {
              if (mounted) {
                // PdfTextSearchResult().clear();
                // PdfTextSearchResult().dispose();
                log('searching on..  . ${pdfs.indexOf(pdf)}');

                var searchResults =
                    pdf.searchText(searchTextController.text.trim(),
                        // searchText.trim(),
                        searchOption: TextSearchOption.wholeWords);

                // log(searchResults.toString());
                // setState(() {
                // ref
                //     .read(searchResult)
                //     .add(searchResults); // Add the search result to the list
                log('Total Instances: ${searchResults.totalInstanceCount}');
                // });
                // }
                // }
              }
            } else {
              // for (PdfViewerController pdf in pdfs) {
              // if (pdf.pageCount > 0) {
              // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              //   content: Text('Searching for ${searchTextController.text.trim()}'),
              // ));
              if (mounted) {
                // PdfTextSearchResult().clear();
                // Future.delayed(Duration(seconds: 2), () {
                // if (_secondPdfViewerKey.currentWidget != null) {
                //   log('Second PDF Viewer Key From Parent Search: ${_secondPdfViewerKey.currentState}');
                // }
                log('searching on..  . ${pdfs.indexOf(pdf)}');
                try {
                  var searchResults = pdf.searchText(
                    searchTextController.text.trim(),
                    // searchText.trim(),
                    // searchOption: TextSearchOption.wholeWords,
                  );
                  log('Total Instances: ${searchResults.totalInstanceCount}');
                } catch (e) {
                  log('Pdf Error: $e');
                }
                // try {
                //   var searchResults = firstPdfController.searchText(
                //     // searchTextController.text.trim()
                //     searchText.trim(),
                //   );
                //   log('Total Instances: ${searchResults.totalInstanceCount}');
                // } catch (e) {
                //   log('First Pdf Error: $e');
                // }
                // try {
                //   var searchResults = splitPdfController.searchText(
                //     // searchTextController.text.trim()
                //     searchText.trim(),
                //   );
                //   log('Total Instances: ${searchResults.totalInstanceCount}');
                // } catch (e) {
                //   log('Split Pdf Error: $e');
                // }
                // try {
                //   var searchResults = thirdPdfController.searchText(
                //     // searchTextController.text.trim()
                //     searchText.trim(),
                //   );
                //   log('Total Instances: ${searchResults.totalInstanceCount}');
                // } catch (e) {
                //   log('Third Pdf Error: $e');
                // }
                // try {
                //   var searchResults = fourthPdfController.searchText(
                //     // searchTextController.text.trim()
                //     searchText.trim(),
                //   );
                //   log('Total Instances: ${searchResults.totalInstanceCount}');
                // } catch (e) {
                //   log('Fourth Pdf Error: $e');
                // }
                // PdfTextSearchResult().dispose();
                // });
                // log(searchResults.toString());
                // setState(() {
                //   ref
                //       .read(searchResult)
                //       .add(searchResults); // Add the search result to the list
                //   log(searchResults.totalInstanceCount.toString());
                // });
              }
              // }
              // }
            }
          }
        }
      }
    });
  }

  Color? getChipColor(String pdfId) {
    if (ref.watch(currentPdfProvider.notifier).state?.pdfId == pdfId) {
      return Colors.green.withOpacity(0.7);
    } else if (ref.watch(splitPdfProvider.notifier).state?.pdfId == pdfId) {
      return Colors.deepPurple.withOpacity(0.7);
    } else if (ref.watch(thirdPdfProvider.notifier).state?.pdfId == pdfId) {
      return Colors.deepPurple.withOpacity(0.7);
    } else if (ref.watch(fourthPdfProvider.notifier).state?.pdfId == pdfId) {
      return Colors.deepPurple.withOpacity(0.7);
    } else {
      return null;
    }
  }

  setZoomLevel(double value) {
    if (ref.read(isFirstPdfActive)) {
      firstPdfController.zoomLevel = value;
    }
    if (ref.read(isSecondPdfActive)) {
      splitPdfController.zoomLevel = value;
    }
    if (ref.read(isThirdPdfActive)) {
      thirdPdfController.zoomLevel = value;
    }
    if (ref.read(isFourthPdfActive)) {
      fourthPdfController.zoomLevel = value;
    }
  }

// previousSwitcher(){
//   if(ref.read(isFirstPdfActive)){
//     firstPdfController.zoomLevel=value;
//   }if(ref.read(isSecondPdfActive)){
//     splitPdfController.zoomLevel=value;
//   }if(ref.read(isThirdPdfActive)){
//     thirdPdfController.zoomLevel=value;
//   }if(ref.read(isFourthPdfActive)){
//     fourthPdfController.zoomLevel=value;
//   }
// }
  double _scale = 1.0;
  bool _isCtrlPressed = false;
  bool _isScrollEvent = false;
  Offset _offset = const Offset(0, 0);
  double defaultZoomLevel = 1;
  // FileInfo? file;
  getFiles(dynamic e) {
    DefaultCacheManager().getFileFromCache(e.pdfId).then(
      (value) {
        // file = value;
        // log('File: ${value?.file}');
        if (value != null) {
          ref.read(tempFileProvider.notifier).add(
                FileModel(fileInfo: value, key: e.pdfId),
              );
          return value;
        }
        return value!;
      },
    );
  }

  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   super.dispose();
  //   // firstPdfController.dispose();
  //   // splitPdfController.dispose();
  //   // thirdPdfController.dispose();
  //   // fourthPdfController.dispose();
  //   searchTextController.dispose();
  //   _searchTimer?.cancel();
  // }

  @override
  Widget build(BuildContext context) {
    final List<PdfFile> files = ref.watch(pdfFilesProvider);
    final selectedFiles = ref.watch(selectedPdfFilesProvider);
    // log('PDFFILES ${ref.watch(pdfFilesProvider).length}');
    return Container(
        // height: 200,
        // width: 500,
        color: Colors.grey[900],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 50,
              width: ref.watch(isLeftSectionOpen)
                  ? MediaQuery.of(context).size.width - 300
                  : MediaQuery.of(context).size.width - 50,
              child: Stack(children: [
                ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    children: files.map((e) {
                      bool isSelected = false;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                            onTap: () {
                              ref.read(currentPdfProvider.notifier).state = e;
                            },
                            child: Row(children: [
                              ref.watch(isComparingProvider)
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          left: 2.0, right: 2.0),
                                      child: CustomCheckbox(
                                        pdfFile: e,
                                        onChanged: (bool? newValue) {
                                          // setState(() {
                                          searchTextController.clear();
                                          searchText = '';
                                          // });
                                          if (newValue == true) {
                                            if (selectedFiles.length < 4) {
                                              // if (mounted) {
                                              searchTextController.clear();
                                              if (!ref
                                                  .read(
                                                      selectedPdfFilesProvider)
                                                  .contains(e)) {
                                                ref
                                                    .read(
                                                        selectedPdfFilesProvider
                                                            .notifier)
                                                    .addPdfFile(e);
                                                if (ref
                                                        .read(
                                                            pdfControllersProvider)
                                                        .length <
                                                    4) {
                                                  ref
                                                      .read(
                                                          pdfControllersProvider
                                                              .notifier)
                                                      .addController(
                                                          PdfViewerController());
                                                }
                                                log('Selected files length: ${ref.watch(selectedPdfFilesProvider).length}');
                                                log('temp file length: ${ref.watch(tempFileProvider).length}');
                                              }
                                              // }

                                              PdfViewerController? controller;

                                              GlobalKey<SfPdfViewerState>? key;
                                              // for (int index = 0;
                                              //     index <=
                                              //         ref
                                              //             .read(
                                              //                 selectedPdfFilesProvider)
                                              //             .length;
                                              //     index++) {
                                              //   switch (index) {
                                              //     case 0:
                                              //       controller =
                                              //           firstPdfController;
                                              //       WidgetsBinding.instance
                                              //           .addPostFrameCallback(
                                              //               (_) {
                                              //         ref
                                              //             .read(
                                              //                 pdfControllersProvider)
                                              //             .replaceRange(0, 0, [
                                              //           firstPdfController
                                              //         ]);
                                              //         log("firstPdfController initialized");
                                              //
                                              //         // setState(() {});
                                              //         // log('PDF Controllers: ${ref.watch(pdfControllersProvider)}');
                                              //       });
                                              //       break;
                                              //     case 1:
                                              //       controller =
                                              //           splitPdfController;
                                              //       WidgetsBinding.instance
                                              //           .addPostFrameCallback(
                                              //               (_) {
                                              //         // if (ref.read(pdfControllersProvider).any(
                                              //         //     (element) =>
                                              //         //         element == splitPdfController)) {
                                              //         //   // ref
                                              //         //   //     .read(pdfControllersProvider.notifier)
                                              //         //   //     .removeController(1);
                                              //         //   // log("splitPdfController removed");
                                              //         // } else {
                                              //         ref
                                              //             .read(
                                              //                 pdfControllersProvider)
                                              //             .replaceRange(1, 1, [
                                              //           splitPdfController
                                              //         ]);
                                              //         log("splitPdfController initialized");
                                              //         // }
                                              //         // setState(() {});
                                              //         // log('PDF Controllers: ${ref.watch(pdfControllersProvider)}');
                                              //       });
                                              //       break;
                                              //     case 2:
                                              //       controller =
                                              //           thirdPdfController;
                                              //       WidgetsBinding.instance
                                              //           .addPostFrameCallback(
                                              //               (_) {
                                              //         // if (ref.read(pdfControllersProvider).any(
                                              //         //     (element) =>
                                              //         //         element == thirdPdfController)) {
                                              //         //   // ref
                                              //         //   //     .read(pdfControllersProvider.notifier)
                                              //         //   //     .removeController(2);
                                              //         //   // log("thirdPdfController removed");
                                              //         // } else {
                                              //         ref
                                              //             .read(
                                              //                 pdfControllersProvider)
                                              //             .replaceRange(2, 2, [
                                              //           thirdPdfController
                                              //         ]);
                                              //         log("thirdPdfController initialized");
                                              //         // }
                                              //         // setState(() {});
                                              //         // log("PDF Controllers: ${ref.watch(pdfControllersProvider)}");
                                              //       });
                                              //       break;
                                              //     case 3:
                                              //       controller =
                                              //           fourthPdfController;
                                              //       WidgetsBinding.instance
                                              //           .addPostFrameCallback(
                                              //               (_) {
                                              //         // if (ref.read(pdfControllersProvider).any(
                                              //         //     (element) =>
                                              //         //         element == fourthPdfController)) {
                                              //         //   // ref
                                              //         //   //     .read(pdfControllersProvider.notifier)
                                              //         //   //     .removeController(3);
                                              //         //   // log("fourthPdfController removed");
                                              //         // } else {
                                              //         ref
                                              //             .read(
                                              //                 pdfControllersProvider)
                                              //             .replaceRange(3, 3, [
                                              //           fourthPdfController
                                              //         ]);
                                              //         log("fourthPdfController initialized");
                                              //         // }
                                              //         // setState(() {});
                                              //         // log("PDF Controllers: ${ref.watch(pdfControllersProvider)}");
                                              //       });
                                              //       break;
                                              //     default:
                                              //       // Handle the case when there are more than 4 PDF files
                                              //       throw Exception(
                                              //           'No controller assigned for index $index');
                                              //   }
                                              //
                                              //   switch (index) {
                                              //     case 0:
                                              //       key = _firstPdfViewerKey;
                                              //       break;
                                              //     case 1:
                                              //       key = _secondPdfViewerKey;
                                              //       break;
                                              //     case 2:
                                              //       key = _thirdPdfViewerKey;
                                              //       break;
                                              //     case 3:
                                              //       key = _fourthPdfViewerKey;
                                              //       break;
                                              //     default:
                                              //       // Handle the case when there are more than 4 PDF files
                                              //       throw Exception(
                                              //           'No key assigned for index $index');
                                              //   }
                                              // }
                                              ref
                                                  .read(pdfWidgetsProvider
                                                      .notifier)
                                                  .addWidget(SizedBox(
                                                    height: 300,
                                                    width: 500,
                                                    child: ref
                                                                .watch(
                                                                    selectedPdfFilesProvider)
                                                                .length <=
                                                            3
                                                        ? ref
                                                                .watch(
                                                                    tempFileProvider)
                                                                .any((element) =>
                                                                    element
                                                                        .key ==
                                                                    e.pdfId)
                                                            ? Stack(children: [
                                                                buildPdfViewer(
                                                                  ref
                                                                      .watch(
                                                                          tempFileProvider)
                                                                      .firstWhere((element) =>
                                                                          element
                                                                              .key ==
                                                                          e.pdfId)
                                                                      .fileInfo
                                                                      .file,
                                                                  e,
                                                                  key: ValueKey(
                                                                      e.pdfId),
                                                                  () {
                                                                    int index = ref
                                                                        .read(
                                                                            selectedPdfFilesProvider)
                                                                        .indexOf(
                                                                            e);
                                                                    if (index >=
                                                                            0 &&
                                                                        index <
                                                                            4) {
                                                                      if (mounted) {
                                                                        return ref
                                                                            .read(pdfControllersProvider)[index];
                                                                      } else {
                                                                        return null;
                                                                      }
                                                                    }
                                                                    return controller;
                                                                  }(),
                                                                  onTap:
                                                                      (details) {
                                                                    if (mounted) {
                                                                      // Perform operations on the PDF viewer
                                                                      log('Selected PDF Index: ${ref.watch(selectedPdfFilesProvider).indexOf(e)}');
                                                                    }

                                                                    // ref
                                                                    //     .read(selectedPdfIdProvider
                                                                    //         .notifier)
                                                                    //     .state = e.pdfId;
                                                                    // ref
                                                                    //     .read(selectedPdfControllerProvider
                                                                    //         .notifier)
                                                                    //     .state = controller;
                                                                    // if (controller ==
                                                                    //     firstPdfController) {
                                                                    //   log('firstPdfController selected');
                                                                    //   ref
                                                                    //       .read(
                                                                    //           selectedIndexProvider.notifier)
                                                                    //       .state = 0;
                                                                    // } else if (controller ==
                                                                    //     splitPdfController) {
                                                                    //   log('splitPdfController selected');
                                                                    //   ref
                                                                    //       .read(
                                                                    //           selectedIndexProvider.notifier)
                                                                    //       .state = 1;
                                                                    // } else if (controller ==
                                                                    //     thirdPdfController) {
                                                                    //   log('thirdPdfController selected');
                                                                    //   ref
                                                                    //       .read(
                                                                    //           selectedIndexProvider.notifier)
                                                                    //       .state = 2;
                                                                    // } else {
                                                                    //   log('fourthPdfController selected');
                                                                    //   ref
                                                                    //       .read(
                                                                    //           selectedIndexProvider.notifier)
                                                                    //       .state = 3;
                                                                    // }
                                                                    // log('Selected Controller Index: ${ref.watch(selectedIndexProvider)}');
                                                                    // log('Selected Pdf Controller: ${ref.watch(selectedPdfControllerProvider)}');
                                                                    // log('Selected PDF ID: ${ref.watch(selectedPdfIdProvider)}');
                                                                  },
                                                                ),
                                                                if (_isScrollEvent &&
                                                                    _isCtrlPressed)
                                                                  GestureDetector(
                                                                    onTapDown:
                                                                        (details) {
                                                                      // setState(() {
                                                                      _isScrollEvent =
                                                                          false;
                                                                      // });
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      color: Colors
                                                                          .transparent,
                                                                    ),
                                                                  ),
                                                                // if (ref.watch(
                                                                //         selectedPdfIdProvider) ==
                                                                //     e.pdfId)
                                                                //   Container(
                                                                //     width: 70,
                                                                //     height: 30,
                                                                //     decoration:
                                                                //         BoxDecoration(
                                                                //       color: Colors
                                                                //           .green,
                                                                //       borderRadius:
                                                                //           BorderRadius.circular(
                                                                //               150),
                                                                //     ),
                                                                //     margin:
                                                                //         const EdgeInsets
                                                                //             .all(
                                                                //             8.0),
                                                                //     child:
                                                                //         const Padding(
                                                                //       padding: EdgeInsets.symmetric(
                                                                //           horizontal:
                                                                //               8.0,
                                                                //           vertical:
                                                                //               2.0),
                                                                //       child:
                                                                //           Center(
                                                                //         child:
                                                                //             Text(
                                                                //           "Active",
                                                                //           style:
                                                                //               TextStyle(
                                                                //             color:
                                                                //                 Colors.white,
                                                                //             fontSize:
                                                                //                 15,
                                                                //             fontWeight:
                                                                //                 FontWeight.bold,
                                                                //           ),
                                                                //         ),
                                                                //       ),
                                                                //     ),
                                                                //   )
                                                              ])
                                                            : Stack(
                                                                children: [
                                                                  buildPdfViewer(
                                                                    e.pdfUrl
                                                                        .toString(),
                                                                    e,
                                                                    key: ValueKey(
                                                                        e.pdfId),
                                                                    () {
                                                                      int index = ref
                                                                          .read(
                                                                              selectedPdfFilesProvider)
                                                                          .indexOf(
                                                                              e);
                                                                      if (index >=
                                                                              0 &&
                                                                          index <
                                                                              4) {
                                                                        if (mounted) {
                                                                          return ref
                                                                              .read(pdfControllersProvider)[index];
                                                                        } else {
                                                                          return null;
                                                                        }
                                                                      }
                                                                      return controller;
                                                                    }(),
                                                                    isNetwork:
                                                                        true,
                                                                    onTap:
                                                                        (details) {
                                                                      log('Selected PDF Index: ${ref.watch(selectedPdfFilesProvider).indexOf(e)}');
                                                                      // ref.read(selectedPdfIdProvider.notifier).state =
                                                                      //     e.pdfId;
                                                                      // ref.read(selectedPdfControllerProvider.notifier).state =
                                                                      //     controller;
                                                                      // if (controller ==
                                                                      //     firstPdfController) {
                                                                      //   ref.read(selectedIndexProvider.notifier).state =
                                                                      //       0;
                                                                      // } else if (controller ==
                                                                      //     splitPdfController) {
                                                                      //   ref.read(selectedIndexProvider.notifier).state =
                                                                      //       1;
                                                                      // } else if (controller ==
                                                                      //     thirdPdfController) {
                                                                      //   ref.read(selectedIndexProvider.notifier).state =
                                                                      //       2;
                                                                      // } else {
                                                                      //   ref.read(selectedIndexProvider.notifier).state =
                                                                      //       3;
                                                                      // }
                                                                      // log('Selected Controller Index: ${ref.watch(selectedIndexProvider)}');
                                                                      // log('Selected Pdf Controller: ${ref.watch(selectedPdfControllerProvider)}');
                                                                      // log('Selected PDF ID: ${ref.watch(selectedPdfIdProvider)}');
                                                                    },
                                                                  ),
                                                                  if (_isScrollEvent &&
                                                                      _isCtrlPressed)
                                                                    GestureDetector(
                                                                      onTapDown:
                                                                          (details) {
                                                                        // setState(() {
                                                                        _isScrollEvent =
                                                                            false;
                                                                        // });
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        color: Colors
                                                                            .transparent,
                                                                      ),
                                                                    ),
                                                                  if (ref.watch(
                                                                          selectedPdfIdProvider) ==
                                                                      e.pdfId)
                                                                    Container(
                                                                      width: 70,
                                                                      height:
                                                                          30,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .green,
                                                                        borderRadius:
                                                                            BorderRadius.circular(150),
                                                                      ),
                                                                      margin: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child:
                                                                          const Padding(
                                                                        padding: EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                8.0,
                                                                            vertical:
                                                                                2.0),
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Text(
                                                                            "Active",
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 15,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    )
                                                                ],
                                                              )
                                                        : Container(),
                                                  ));
                                            } else {
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: const Text('Alert',
                                                      style: TextStyle(
                                                          color: Colors.amber,
                                                          fontSize: 24)),
                                                  content: const Text(
                                                      'You can select only 4 files',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 20)),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      child: const Text('Ok'),
                                                    )
                                                  ],
                                                ),
                                              );
                                            }
                                          } else {
                                            if (mounted) {
                                              searchTextController.clear();
                                            }
                                            // ref
                                            //     .read(
                                            //         pdfWidgetsProvider.notifier)
                                            //     .removeWidget(ref
                                            //         .watch(
                                            //             selectedPdfFilesProvider)
                                            //         .indexOf(e));

                                            _searchTimer?.cancel();
                                            // ref
                                            //     .read(pdfControllersProvider
                                            //         .notifier)
                                            //     .removeController(
                                            //       selectedFiles.indexOf(e),
                                            //     );
                                            log('Index of selected file: ${selectedFiles.indexOf(e)}');
                                            // for (int i = 0;
                                            //     i < selectedFiles.length;
                                            //     i++) {
                                            //   if (selectedFiles[i] == e) {
                                            //     ref
                                            //         .read(pdfControllersProvider
                                            //             .notifier)
                                            //         .removeController(i);
                                            //     log('Controller removed at index $i and length is ${ref.watch(pdfControllersProvider).length}');
                                            //     ref
                                            //         .watch(
                                            //             pdfControllersProvider)
                                            //         .clear();
                                            //   }
                                            // }

                                            // if index == 0 then dispose the first controller
                                            int index =
                                                selectedFiles.indexOf(e);
                                            setState(() {
                                              if (index <
                                                  ref
                                                      .read(
                                                          pdfControllersProvider)
                                                      .length) {
                                                ref
                                                    .read(pdfControllersProvider)[
                                                        index]
                                                    .dispose();
                                                ref
                                                    .read(
                                                        pdfControllersProvider)
                                                    .removeAt(index);
                                              }
                                              ref
                                                  .read(pdfWidgetsProvider)
                                                  .removeAt(index);
                                            });
                                            log('Controllers Length ${ref.read(pdfControllersProvider).length}');
                                            ref
                                                .read(selectedPdfFilesProvider
                                                    .notifier)
                                                .removePdfFile(e);
                                            if (ref.watch(tempFileProvider).any(
                                                (element) =>
                                                    element.key != e.pdfId)) {
                                              // ref
                                              //     .read(
                                              //         tempFileProvider.notifier)
                                              //     .remove(e.pdfId);
                                            }
                                          }
                                          // for (PdfViewerController controller
                                          //     in ref.watch(
                                          //         pdfControllersProvider)) {
                                          // controller.clearSelection();
                                          // firstPdfController.clearSelection();
                                          // splitPdfController.clearSelection();
                                          // thirdPdfController.clearSelection();
                                          // fourthPdfController
                                          //     .clearSelection();
                                          // setState(() {});
                                          setState(() {
                                            isSearched = false;
                                          });
                                          log('Controllers Length ${ref.read(pdfControllersProvider).length}');
                                          // }
                                          log('Selected files: ${ref.read(selectedPdfFilesProvider).length}');
                                        },
                                      ))
                                  : Container(),
                              Chip(
                                label: Text(e.pdfName),
                                avatar: ref
                                            .watch(currentPdfProvider.notifier)
                                            .state
                                            ?.pdfId ==
                                        e.pdfId
                                    ? const Icon(
                                        Icons.check_circle_outline_rounded)
                                    : null,
                                shape: const StadiumBorder(),
                                backgroundColor: getChipColor(e.pdfId),
                                onDeleted: () {
                                  searchTextController.clear();
                                  _searchTimer?.cancel();
                                  ref
                                      .read(selectedPdfFilesProvider.notifier)
                                      .state
                                      .remove(e);
                                  if (ref
                                      .watch(selectedPdfFilesProvider)
                                      .isEmpty) {
                                    ref
                                        .read(isComparingProvider.notifier)
                                        .state = false;
                                  }
                                  // setState(() {
                                  ref
                                      .read(tempFileProvider.notifier)
                                      .remove(e.pdfId);
                                  ref
                                      .read(pdfFilesProvider.notifier)
                                      .removePdfFile(e);
                                  // Future.delayed(Duration(seconds: 2), () {

                                  // });

                                  files.removeWhere(
                                      (element) => element.pdfId == e.pdfId);

                                  // Check if the deleted file was the current PDF
                                  if (ref.read(currentPdfProvider)?.pdfId ==
                                      e.pdfId) {
                                    // Find the next available PDF file
                                    final nextPdf =
                                        files.isNotEmpty ? files.first : null;
                                    ref
                                        .read(currentPdfProvider.notifier)
                                        .state = nextPdf;
                                  }

                                  // Update other providers
                                  if (ref.read(splitPdfProvider)?.pdfId ==
                                      e.pdfId) {
                                    ref.read(splitPdfProvider.notifier).state =
                                        null;
                                  }
                                  if (ref.read(thirdPdfProvider)?.pdfId ==
                                      e.pdfId) {
                                    ref.read(thirdPdfProvider.notifier).state =
                                        null;
                                  }
                                  if (ref.read(fourthPdfProvider)?.pdfId ==
                                      e.pdfId) {
                                    ref.read(fourthPdfProvider.notifier).state =
                                        null;
                                  }
                                  // });
                                },
                              ),
                            ])),
                      );
                    }).toList()),
                Positioned(
                    right: 10,
                    child: IconButton.filledTonal(
                        onPressed: () {
                          ref.read(isComparingProvider.notifier).state =
                              !ref.read(isComparingProvider.notifier).state;

                          // log('Comparing: ${ref.read(isComparingProvider)}');
                          // if (ref.read(splitPdfProvider) == null) {
                          //   ref.read(splitPdfProvider.notifier).state =
                          //       ref.read(currentPdfProvider);
                          // } else if (ref.read(thirdPdfProvider) == null) {
                          //   ref.read(thirdPdfProvider.notifier).state =
                          //       ref.read(currentPdfProvider);
                          // } else if (ref.read(fourthPdfProvider) == null) {
                          //   ref.read(fourthPdfProvider.notifier).state =
                          //       ref.read(currentPdfProvider);
                          // }
                        },
                        icon: Container(
                            // width: 70,
                            // height: 30,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            decoration: BoxDecoration(
                              // color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(150),
                            ),
                            child: Text(
                                ref.read(isComparingProvider.notifier).state ==
                                        false
                                    ? "Compare"
                                    : "Stop Comparing",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold)))))
              ]),
            ),
            Flexible(
                child: ref.watch(isComparingProvider) &&
                        ref.watch(selectedPdfFilesProvider).isNotEmpty
                    ? LayoutBuilder(
                        builder: (context, constraints) {
                          double width =
                              ref.watch(selectedPdfFilesProvider).isNotEmpty
                                  ? constraints.maxWidth / 2.1
                                  : constraints.maxWidth;
                          double height =
                              ref.watch(selectedPdfFilesProvider).length > 2
                                  ? constraints.maxHeight / 2
                                  : constraints.maxHeight;
                          return Wrap(
                            spacing: 1,
                            runSpacing: 1,
                            children: ref.watch(pdfWidgetsProvider),
                          );
                        },
                      )
                    : Stack(
                        children: [
                          ref.watch(tempFileProvider).any((element) =>
                                  element.key ==
                                  ref.watch(currentPdfProvider)?.pdfId)
                              ? Stack(
                                  children: [
                                    buildPdfViewer(
                                        ref
                                            .watch(tempFileProvider)
                                            .firstWhere((element) =>
                                                element.key ==
                                                ref
                                                    .watch(currentPdfProvider)
                                                    ?.pdfId)
                                            .fileInfo
                                            .file,
                                        ref.watch(currentPdfProvider) ??
                                            PdfFile(
                                                pdfId: 'pdf123',
                                                pdfName: 'nothing',
                                                pdfUrl:
                                                    'https://bibliothek.wzb.eu/pdf/2016/ii16-212.pdf'),
                                        firstPdfController,
                                        key: _firstPdfViewerKey,
                                        onTap: (details) {
                                      // ref
                                      //         .read(selectedPdfIdProvider.notifier)
                                      //         .state =
                                      //     ref.watch(currentPdfProvider)!.pdfId;
                                      ref
                                          .read(selectedPdfControllerProvider
                                              .notifier)
                                          .state = firstPdfController;
                                      ref
                                          .read(selectedIndexProvider.notifier)
                                          .state = 0;
                                      log('Selected Pdf Controller: ${ref.watch(selectedPdfControllerProvider)}');
                                      log('Selected PDF ID: ${ref.watch(selectedPdfIdProvider)}');
                                    }),
                                    if (_isScrollEvent && _isCtrlPressed)
                                      GestureDetector(
                                        onTapDown: (details) {
                                          // setState(() {
                                          _isScrollEvent = false;
                                          // });
                                        },
                                        child: Container(
                                          color: Colors.transparent,
                                        ),
                                      ),
                                    // if (ref.watch(selectedPdfIdProvider) ==
                                    //     ref.watch(currentPdfProvider)!.pdfId)
                                    //   Container(
                                    //     width: 70,
                                    //     height: 30,
                                    //     decoration: BoxDecoration(
                                    //       color: Colors.green,
                                    //       borderRadius:
                                    //           BorderRadius.circular(150),
                                    //     ),
                                    //     margin: const EdgeInsets.all(8.0),
                                    //     child: const Padding(
                                    //       padding: EdgeInsets.symmetric(
                                    //           horizontal: 8.0, vertical: 2.0),
                                    //       child: Center(
                                    //         child: Text(
                                    //           "Active",
                                    //           style: TextStyle(
                                    //             color: Colors.white,
                                    //             fontSize: 15,
                                    //             fontWeight: FontWeight.bold,
                                    //           ),
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   )
                                  ],
                                )
                              : Stack(
                                  children: [
                                    buildPdfViewer(
                                        ref
                                            .watch(currentPdfProvider)
                                            ?.pdfUrl
                                            .toString(),
                                        ref.watch(currentPdfProvider) ??
                                            PdfFile(
                                                pdfId: 'pdf123',
                                                pdfName: 'nothing',
                                                pdfUrl:
                                                    'https://bibliothek.wzb.eu/pdf/2016/ii16-212.pdf'),
                                        firstPdfController,
                                        key: _firstPdfViewerKey,
                                        onTap: (details) {
                                      // ref
                                      //         .read(selectedPdfIdProvider.notifier)
                                      //         .state =
                                      //     ref.watch(currentPdfProvider)!.pdfId;
                                      ref
                                          .read(selectedIndexProvider.notifier)
                                          .state = 0;
                                      log('Selected PDF ID: ${ref.watch(selectedPdfIdProvider)}');
                                    }, isNetwork: true),
                                    if (_isScrollEvent && _isCtrlPressed)
                                      GestureDetector(
                                        onTapDown: (details) {
                                          // setState(() {
                                          _isScrollEvent = false;
                                          // });
                                        },
                                        child: Container(
                                          color: Colors.transparent,
                                        ),
                                      ),
                                    // if (ref.watch(selectedPdfIdProvider) ==
                                    //     ref.watch(currentPdfProvider)?.pdfId)
                                    //   Container(
                                    //     width: 70,
                                    //     height: 30,
                                    //     decoration: BoxDecoration(
                                    //       color: Colors.green,
                                    //       borderRadius:
                                    //           BorderRadius.circular(150),
                                    //     ),
                                    //     margin: const EdgeInsets.all(8.0),
                                    //     child: const Padding(
                                    //       padding: EdgeInsets.symmetric(
                                    //           horizontal: 8.0, vertical: 2.0),
                                    //       child: Center(
                                    //         child: Text(
                                    //           "Active",
                                    //           style: TextStyle(
                                    //             color: Colors.white,
                                    //             fontSize: 15,
                                    //             fontWeight: FontWeight.bold,
                                    //           ),
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   )
                                  ],
                                ),
                          if (_isScrollEvent && _isCtrlPressed)
                            GestureDetector(
                              onTapDown: (details) {
                                // setState(() {
                                _isScrollEvent = false;
                                // });
                              },
                              child: Container(
                                color: Colors.transparent,
                              ),
                            ),
                          if (ref.watch(isFirstPdfActive))
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                width: 70,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(150),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Active",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ))
          ],
        ));
  }

  Widget buildPdfViewer(
      dynamic source, PdfFile e, PdfViewerController? controller,
      {bool isNetwork = false,
      required key,
      required Function(PdfGestureDetails) onTap}) {
    return isNetwork
        ? SfPdfViewer.network(
            source,
            key: key,
            controller: controller,
            // undoController: UndoHistoryController(),
            onDocumentLoaded: (PdfDocumentLoadedDetails details) async {
              log('Controllers Length ${ref.read(pdfControllersProvider).length}');

              if (isNetwork) {
                final file = await DefaultCacheManager().downloadFile(
                  e.pdfUrl,
                  key: e.pdfId,
                );
                ref.read(tempFileProvider.notifier).add(
                      FileModel(fileInfo: file, key: e.pdfId),
                    );
              }

              ref.read(isFirstWidgetRenderedProvider.notifier).state = true;
              // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              //   backgroundColor: isNetwork ? Colors.green : Colors.blue,
              //   content: Text(
              //     '${e.pdfId} Document loaded from ${isNetwork ? 'network and cached' : 'cache'}',
              //     style: TextStyle(color: Colors.white),
              //   ),
              // ));
            },
            onDocumentLoadFailed: (details) {
              ref.read(isFirstWidgetRenderedProvider.notifier).state = false;
            },
            onTap: onTap,
            canShowTextSelectionMenu: false,
            interactionMode:
                _isCtrlPressed || ref.watch(isPanActive.notifier).state
                    ? PdfInteractionMode.pan
                    : PdfInteractionMode.selection,
            maxZoomLevel: 5000,
            scrollDirection: PdfScrollDirection.vertical,
            currentSearchTextHighlightColor: Colors.red.withOpacity(0.5),
            otherSearchTextHighlightColor: Colors.green.withOpacity(0.5),
            onTextSelectionChanged: (details) {
              // log('searching in network...');
              // if()
              // if (isSearched == false) {
              if (mounted) {
                if (details.selectedText != null) {
                  // log('PageCount: ${controller.pageCount.toString()}');
                  // setState(() {
                  if (details.selectedText != null ||
                      details.selectedText != '') {
                    searchTextController.text = details.selectedText!.trim();
                  }
                  // });

                  // setState(() {
                  searchText = details.selectedText ?? '';
                  // });
                  // _searchTimer?.cancel();
                  // _searchTimer = Timer(const Duration(seconds: 0), () {
                  // log('PageCount: ${controller.pageCount.toString()}');

                  // if (key.currentState != null) {
                  //   // log('Second PDF Viewer Key: ${key.currentState}');
                  // }
                  // WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (controller != null) {
                    if (controller == firstPdfController) {
                      log('First PDF Controller');
                    }
                    if (controller == splitPdfController) {
                      log('Split PDF Controller');
                    }
                    if (controller == thirdPdfController) {
                      log('Third PDF Controller');
                    }
                    if (controller == fourthPdfController) {
                      log('Fourth PDF Controller');
                    }
                    // performSearch([
                    //   firstPdfController,
                    //   splitPdfController,
                    //   thirdPdfController,
                    //   fourthPdfController
                    // ]);
                  }

                  performSearch(ref.read(pdfControllersProvider));
                  // });
                  // });

                  log('Selected Text: ${details.selectedText}');
                  // }
                }
              }
            },
            onZoomLevelChanged: (details) {},
          )
        : SfPdfViewer.file(
            source,
            // key: ValueKey(e.pdfId),
            onDocumentLoaded: (PdfDocumentLoadedDetails details) {
              if (mounted) {
                log('Controllers loaded Length ${ref.read(pdfControllersProvider).length}');

                // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                //   backgroundColor: Colors.blue,
                //   content: Text(
                //     '${e.pdfId} Document loaded from file',
                //     style: TextStyle(color: Colors.white),
                //   ),
                // ));
              }
            },
            // undoController: UndoHistoryController(),

            onTap: onTap,
            key: key,
            canShowTextSelectionMenu: false,
            controller: controller,
            interactionMode:
                _isCtrlPressed || ref.watch(isPanActive.notifier).state
                    ? PdfInteractionMode.pan
                    : PdfInteractionMode.selection,
            maxZoomLevel: 5000,
            canShowPageLoadingIndicator: false,
            onDocumentLoadFailed: (details) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(
                    '${e.pdfId} Document failed to load',
                    style: const TextStyle(color: Colors.white),
                  ),
                ));
              }
            },
            scrollDirection: PdfScrollDirection.vertical,
            currentSearchTextHighlightColor: Colors.red.withOpacity(0.5),
            otherSearchTextHighlightColor: Colors.green.withOpacity(0.5),
            onTextSelectionChanged: (details) {
              // log('searching in file...');
              // if (isSearched == false) {
              //   if (_secondPdfViewerKey.currentWidget != null) {
              // log('Second PDF Viewer Key: ${_secondPdfViewerKey.currentState}');
              // }
              if (mounted) {
                if (details.selectedText != null) {
                  // log('PageCount: ${controller.pageCount.toString()}');

                  // setState(() {
                  if (details.selectedText != null ||
                      details.selectedText != '') {
                    searchTextController.text = details.selectedText!.trim();
                  }

                  // setState(() {
                  // searchText = details.selectedText ?? '';
                  // });
                  // });
                  // _searchTimer?.cancel();
                  // _searchTimer = Timer(const Duration(seconds: 0), () {
                  // WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (controller != null) {
                    // performSearch([
                    //   firstPdfController,
                    //   splitPdfController,
                    //   thirdPdfController,
                    //   fourthPdfController
                    // ]);
                  }
                  performSearch(ref.read(pdfControllersProvider));
                  // });
                  // });
                  log('Selected Text: ${details.selectedText}');
                }
              }
              // }
            },
            // onZoomLevelChanged: (details) {},
          );
  }
}
