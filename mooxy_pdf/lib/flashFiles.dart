import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mooxy_pdf/flashFilesDetails.dart';
import 'package:mooxy_pdf/flashFiles_controller.dart';
import 'package:mooxy_pdf/providers.dart';

class FlashFiles extends ConsumerStatefulWidget {
  const FlashFiles({super.key});

  @override
  ConsumerState createState() => _FlashFilesState();
}

class _FlashFilesState extends ConsumerState<FlashFiles> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Flash Files'),
        ),
        body: FutureBuilder<FlashFilesResponse?>(
            future: FlashFilesController().getAllParentFlashFiles(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData) {
                return Text('No flash files found');
              }
              final result = snapshot.data!;
              return Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.start,
                children: result.data.map((file) {
                  return InkWell(
                    onTap: () {
                      FlashFilesController().getAllChildFlashFiles(file.id!);
                      showDialog<void>(
                        context: context,
                        // barrierDismissible: barrierDismissible,
                        // false = user must tap button, true = tap outside dialog
                        builder: (BuildContext dialogContext) {
                          return Dialog(
                              clipBehavior: Clip.hardEdge,
                              child: FlashFilesDetails(
                                fileId: file.id!,
                              ));
                        },
                      );
                    },
                    child: SizedBox(
                      width: 250,
                      height: 250,
                      child: Card(
                        clipBehavior: Clip.hardEdge,
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                              imageUrl:
                                  AppStateProviders.prifixUrl + file.icon!,
                              fit: BoxFit.fill,
                              width: double.maxFinite,
                              height: double.maxFinite,
                              errorWidget: (context, url, error) =>
                                  Center(child: Icon(Icons.error)),
                              placeholder: (context, url) =>
                                  Center(child: CircularProgressIndicator()),
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(file.name)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            }));
  }
}
