import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mooxy_pdf/flashFiles_controller.dart';
import 'package:mooxy_pdf/providers.dart';
import 'package:url_launcher/url_launcher.dart';

class FlashFilesDetails extends ConsumerStatefulWidget {
  final String fileId;
  const FlashFilesDetails({super.key, required this.fileId});

  @override
  ConsumerState createState() => _FlashFilesDetailsState();
}

class _FlashFilesDetailsState extends ConsumerState<FlashFilesDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flash Files'),
      ),
      body: RecursiveFlashFiles(parentId: widget.fileId),
    );
  }
}

class RecursiveFlashFiles extends StatelessWidget {
  final String? parentId;

  const RecursiveFlashFiles({Key? key, this.parentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FlashFilesResponse?>(
      future: FlashFilesController().getAllChildFlashFiles(parentId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return Center(child: Text('No data available'));
        }

        final data = snapshot.data!;

        if (data.data.isEmpty &&
            (data.flashFilesPdf == null || data.flashFilesPdf!.isEmpty)) {
          return Center(child: Text('No files found'));
        }

        return ListView(
          shrinkWrap: true,
          children: [
            ...data.data.map((file) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.all(8.0),
                    leading: Container(
                      width: 45,
                      height: 45,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: CachedNetworkImage(
                        imageUrl: AppStateProviders.prifixUrl + file.icon!,
                        width: double.maxFinite,
                        height: double.maxFinite,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                    title: Text(file.name),
                    children: [
                      if (file.pFlashFiles != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 45,
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.all(8.0),
                                //   child: Icon(Icons.subdirectory_arrow_right_rounded),
                                // ),
                                Flexible(
                                    child:
                                        RecursiveFlashFiles(parentId: file.id)),
                              ],
                            ),
                          ),
                        )
                      else
                        SizedBox.shrink(),
                    ],
                  ),
                )),
            if (data.flashFilesPdf != null)
              ...data.flashFilesPdf!.map((pdfFile) => Card(
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.subdirectory_arrow_right_rounded),
                        ),
                        Flexible(
                          child: ListTile(
                            leading: Container(
                              width: 45,
                              height: 45,
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: pdfFile.icon != null
                                  ? CachedNetworkImage(
                                      imageUrl: AppStateProviders.prifixUrl +
                                          pdfFile.icon!,
                                      width: double.maxFinite,
                                      height: double.maxFinite,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                      placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : CachedNetworkImage(
                                      imageUrl:
                                          'https://www.freeiconspng.com/thumbs/pdf-icon/pdf-icon-3.png',
                                      width: double.maxFinite,
                                      height: double.maxFinite,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                      placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                            ),
                            title: Text(pdfFile.name),
                            subtitle: Text('Click to open file in browser'),
                            onTap: () {
                              // Handle PDF file tap, e.g., open the file or show a preview
                              launchUrl(Uri.parse(pdfFile.fileLink));
                              print('PDF tapped: ${pdfFile.fileLink}');
                            },
                          ),
                        ),
                      ],
                    ),
                  )),
          ],
        );
      },
    );
  }
}
