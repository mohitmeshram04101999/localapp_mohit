// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:pdfx/pdfx.dart';
//
// class CustomPdfView extends StatefulWidget {
//   String pdfUrl;
//   CustomPdfView({super.key, required this.pdfUrl});
//
//   @override
//   State<CustomPdfView> createState() => _CustomPdfViewState();
// }
//
// class _CustomPdfViewState extends State<CustomPdfView> {
//   PdfController? pdfController;
//   PdfControllerPinch? pdfControllerPinch;
//   @override
//   void initState() {
//     super.initState();
//     pdfController = PdfController(
//       document: PdfDocument.openAsset('assets/MAGIC.pdf'),
//     );
//     pdfControllerPinch =
//         PdfControllerPinch(document: PdfDocument.openAsset('assets/MAGIC.pdf'));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('PDF View'),
//       ),
//       body: pdfController != null
//           ? KeyboardListener(
//               focusNode: FocusNode(),
//               onKeyEvent: (value) {},
//               child: Listener(
//                 onPointerSignal: (event) {
//                   if (event is PointerScrollEvent) {
//                     setState(() {
//                       pdfControllerPinch!.value +=
//                           Matrix4.copy(pdfControllerPinch!.value)
//                             ..translate(0, event.scrollDelta.dy / 2);
//                     });
//                   }
//                 },
//                 child: PdfView(
//                   controller: pdfController!,
//                 ),
//               ),
//             )
//           : Center(
//               child: CircularProgressIndicator(),
//             ),
//     );
//   }
// }
