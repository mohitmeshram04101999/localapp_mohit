// import 'package:flutter/material.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mooxy_pdf/right_section.dart';
//
// class PdfViewerWidget extends ConsumerStatefulWidget {
//   final String pdfId;
//   final String pdfUrl;
//   final dynamic e; // Replace `dynamic` with your actual type.
//   final dynamic controller; // Replace `dynamic` with your actual type.
//   final Function onTap; // Replace `Function` with the correct type if known.
//
//   const PdfViewerWidget({
//     Key? key,
//     required this.pdfId,
//     required this.pdfUrl,
//     required this.e,
//     required this.controller,
//     required this.onTap,
//   }) : super(key: key);
//
//   @override
//   _PdfViewerWidgetState createState() => _PdfViewerWidgetState();
// }
//
// class _PdfViewerWidgetState extends ConsumerState<PdfViewerWidget> {
//   FileInfo? _fileInfo;
//   bool _isLoading = true;
//   bool _isScrollEvent =
//       false; // These should be passed or managed appropriately.
//   bool _isCtrlPressed =
//       false; // These should be passed or managed appropriately.
//
//   @override
//   void initState() {
//     super.initState();
//     _loadFile();
//   }
//
//   Future<void> _loadFile() async {
//     final fileInfo = await DefaultCacheManager().getFileFromCache(widget.pdfId);
//     if (fileInfo != null) {
//       setState(() {
//         _fileInfo = fileInfo;
//         _isLoading = false;
//       });
//     } else {
//       // Optionally load from network if not cached
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return _isLoading
//         ? Stack(children: [
//             buildPdfViewer(
//               snapshot.data!.file,
//               e,
//               controller,
//               onTap: (details) {
//                 ref.read(selectedPdfIdProvider.notifier).state = e.pdfId;
//                 log('Selected PDF ID: ${ref.watch(selectedPdfIdProvider)}');
//               },
//             ),
//             if (_isScrollEvent && _isCtrlPressed)
//               GestureDetector(
//                 onTapDown: (details) {
//                   // setState(() {
//                   _isScrollEvent = false;
//                   // });
//                 },
//                 child: Container(
//                   color: Colors.transparent,
//                 ),
//               ),
//             if (ref.watch(selectedPdfIdProvider) == e.pdfId)
//               Container(
//                 width: 70,
//                 height: 30,
//                 decoration: BoxDecoration(
//                   color: Colors.green,
//                   borderRadius: BorderRadius.circular(150),
//                 ),
//                 margin: const EdgeInsets.all(8.0),
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
//                   child: Center(
//                     child: Text(
//                       "Active",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 15,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               )
//           ])
//         : Stack(
//             children: [
//               buildPdfViewer(
//                 e.pdfUrl.toString(),
//                 e,
//                 controller,
//                 isNetwork: true,
//                 onTap: (details) {
//                   ref.read(selectedPdfIdProvider.notifier).state = e.pdfId;
//                   log('Selected PDF ID: ${ref.watch(selectedPdfIdProvider)}');
//                 },
//               ),
//               if (_isScrollEvent && _isCtrlPressed)
//                 GestureDetector(
//                   onTapDown: (details) {
//                     // setState(() {
//                     _isScrollEvent = false;
//                     // });
//                   },
//                   child: Container(
//                     color: Colors.transparent,
//                   ),
//                 ),
//               if (ref.watch(selectedPdfIdProvider) == e.pdfId)
//                 Container(
//                   width: 70,
//                   height: 30,
//                   decoration: BoxDecoration(
//                     color: Colors.green,
//                     borderRadius: BorderRadius.circular(150),
//                   ),
//                   margin: const EdgeInsets.all(8.0),
//                   child: Padding(
//                     padding:
//                         EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
//                     child: Center(
//                       child: Text(
//                         "Active",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 15,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 )
//             ],
//           );
//   }
// }
