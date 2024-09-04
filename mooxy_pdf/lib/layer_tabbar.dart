import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mooxy_pdf/diode_controller.dart';
import 'package:mooxy_pdf/diode_controller.dart' as diode_controller;
import 'package:mooxy_pdf/layer_controller.dart' as layers;
import 'package:mooxy_pdf/left_section.dart';
import 'package:mooxy_pdf/providers.dart';
import 'package:mooxy_pdf/right_section.dart';

StateProvider<layers.SubBrandResponse?> subBrandsProvider =
    StateProvider((ref) => null);

class LayerTabBar extends ConsumerStatefulWidget {
  const LayerTabBar({super.key});

  @override
  ConsumerState createState() => _LayerTabBarState();
}

class _LayerTabBarState extends ConsumerState<LayerTabBar>
    with SingleTickerProviderStateMixin {
  final layers.LayerAppControllers _appControllers =
      layers.LayerAppControllers();
  late Future<layers.BrandResponse> _brandsFuture;
  TabController? _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _brandsFuture = _appControllers.getAllSchematicLayerBrands();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<layers.BrandResponse>(
      future: _brandsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Something went wrong!'));
        } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
          return Center(child: Text('No data available'));
        }

        final layers.BrandResponse brands = snapshot.data!;
        layers.SubBrandResponse subBrands;
        return ListView.builder(
          primary: false,
          itemCount: brands.data.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.all(2.0),
            child: ExpansionTile(
              title: Text('${brands.data[index].name}'),
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(
                  AppStateProviders.prifixUrl + brands.data[index].icon,
                ),
              ),
              onExpansionChanged: (value) async {
                // log(brands.data[index].id??'');
                // layers.LayerAppControllers()
                //     .getAllSchematicLayerBrands();
                ref.read(subBrandsProvider.notifier).state =
                    await _appControllers
                        .getAllSubBrandsByPBrand(brands.data[index].id ?? '');
              },
              children: [
                ref.watch(subBrandsProvider) != null
                    ? ListView.builder(
                        primary: false,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: ref.watch(subBrandsProvider)!.data.length,
                        itemBuilder: (context, innerIndex) => Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: ExpansionTile(
                            title: Text(
                                '${ref.watch(subBrandsProvider)!.data[innerIndex].name}'),
                            leading: CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                AppStateProviders.prifixUrl +
                                    ref
                                        .watch(subBrandsProvider)!
                                        .data[innerIndex]
                                        .icon,
                              ),
                            ),
                            onExpansionChanged: (value) {
                              log(ref
                                      .watch(subBrandsProvider)!
                                      .data[innerIndex]
                                      .id ??
                                  '');
                            },
                            children: [
                              TabBar(controller: _tabController, tabs: [
                                Tab(text: 'FRONT'),
                                Tab(text: 'BACK'),
                              ]),
                              SizedBox(
                                height: 500,
                                child: TabBarView(
                                    controller: _tabController,
                                    children: [
                                      FutureBuilder<
                                          layers.SchematicPdfResponse>(
                                        future: _appControllers
                                            .getAllFrontSubSubBrandsByPBrand(ref
                                                    .watch(subBrandsProvider)!
                                                    .data[innerIndex]
                                                    .id ??
                                                ''),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Center(
                                                child:
                                                    CircularProgressIndicator());
                                          } else if (snapshot.hasError) {
                                            return Center(
                                                child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child:
                                                  Text('Something went wrong!'),
                                            ));
                                          } else if (!snapshot.hasData ||
                                              snapshot
                                                  .data!.data.pdfFile.isEmpty) {
                                            return Center(
                                                child:
                                                    Text('No data available'));
                                          }

                                          final layers.SchematicPdfResponse
                                              schematicPdfs = snapshot.data!;
                                          log(schematicPdfs.data.pdfFile
                                              .toString());
                                          return ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemCount: 1,
                                            itemBuilder:
                                                (context, innerSubIndex) {
                                              layers.SchematicPdf pdfData =
                                                  schematicPdfs.data;
                                              // Filter out null entries and create a list of non-null PDF files
                                              List<String> nonNullPdfFiles =
                                                  pdfData
                                                      .pdfFile
                                                      .where((file) =>
                                                          file != null)
                                                      .cast<String>()
                                                      .toList();

                                              // If there are no non-null PDF files, return an empty container
                                              if (nonNullPdfFiles.isEmpty) {
                                                return Container();
                                              }

                                              return Column(
                                                children: nonNullPdfFiles
                                                    .map((file) => ListTile(
                                                          onTap: () {
                                                            final newPdfFile =
                                                                diode_controller.PdfFile(
                                                                    pdfUrl: AppStateProviders
                                                                            .prifixUrl +
                                                                        file,
                                                                    pdfName: file
                                                                        .split(
                                                                            '/')
                                                                        .last,
                                                                    pdfId:
                                                                        '${pdfData.id}_${file.split('/').last}' // Create a unique ID for each file
                                                                    );

                                                            // Check if the PDF file already exists in the provider
                                                            final pdfFiles =
                                                                ref.read(
                                                                    pdfFilesProvider);
                                                            final pdfFileExists =
                                                                pdfFiles.any((existingFile) =>
                                                                    existingFile
                                                                        .pdfId ==
                                                                    newPdfFile
                                                                        .pdfId);

                                                            if (!pdfFileExists) {
                                                              // Add the PDF file only if it doesn't exist
                                                              ref
                                                                  .read(pdfFilesProvider
                                                                      .notifier)
                                                                  .addPdfFile(
                                                                      newPdfFile);
                                                            }

                                                            // Set the current PDF
                                                            if (ref
                                                                    .read(currentPdfProvider
                                                                        .notifier)
                                                                    .state ==
                                                                null) {
                                                              ref
                                                                  .read(currentPdfProvider
                                                                      .notifier)
                                                                  .state = newPdfFile;
                                                            }
                                                            ref
                                                                .read(currentPdfProvider
                                                                    .notifier)
                                                                .state = newPdfFile;
                                                          },
                                                          tileColor: ref
                                                                  .watch(
                                                                      pdfFilesProvider)
                                                                  .any((element) =>
                                                                      element
                                                                          .pdfUrl ==
                                                                      pdfData.pdfFile[
                                                                          innerSubIndex])
                                                              ? Colors.grey[300]
                                                              : null,
                                                          leading: Icon(Icons
                                                              .picture_as_pdf),
                                                          title: Text(
                                                              'Layer ${nonNullPdfFiles.indexOf(file) + 1}'),
                                                        ))
                                                    .toList(),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                      FutureBuilder<
                                          layers.SchematicPdfResponse>(
                                        future: _appControllers
                                            .getAllBackSubSubBrandsByPBrand(ref
                                                    .watch(subBrandsProvider)!
                                                    .data[innerIndex]
                                                    .id ??
                                                ''),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Center(
                                                child:
                                                    CircularProgressIndicator());
                                          } else if (snapshot.hasError) {
                                            return Center(
                                                child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child:
                                                  Text('Something went wrong!'),
                                            ));
                                          } else if (!snapshot.hasData ||
                                              snapshot
                                                  .data!.data.pdfFile.isEmpty) {
                                            return Center(
                                                child:
                                                    Text('No data available'));
                                          }

                                          final layers.SchematicPdfResponse
                                              schematicPdfs = snapshot.data!;
                                          log(schematicPdfs.data.pdfFile
                                              .toString());
                                          return ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemCount: 1,
                                            itemBuilder:
                                                (context, innerSubIndex) {
                                              layers.SchematicPdf pdfData =
                                                  schematicPdfs.data;
                                              // Filter out null entries and create a list of non-null PDF files
                                              List<String> nonNullPdfFiles =
                                                  pdfData
                                                      .pdfFile
                                                      .where((file) =>
                                                          file != null)
                                                      .cast<String>()
                                                      .toList();

                                              // If there are no non-null PDF files, return an empty container
                                              if (nonNullPdfFiles.isEmpty) {
                                                return Container();
                                              }

                                              return Column(
                                                children: nonNullPdfFiles
                                                    .map((file) => ListTile(
                                                          onTap: () {
                                                            final newPdfFile =
                                                                diode_controller.PdfFile(
                                                                    pdfUrl: AppStateProviders
                                                                            .prifixUrl +
                                                                        file,
                                                                    pdfName: file
                                                                        .split(
                                                                            '/')
                                                                        .last,
                                                                    pdfId:
                                                                        '${pdfData.id}_${file.split('/').last}' // Create a unique ID for each file
                                                                    );

                                                            // Check if the PDF file already exists in the provider
                                                            final pdfFiles =
                                                                ref.read(
                                                                    pdfFilesProvider);
                                                            final pdfFileExists =
                                                                pdfFiles.any((existingFile) =>
                                                                    existingFile
                                                                        .pdfId ==
                                                                    newPdfFile
                                                                        .pdfId);

                                                            if (!pdfFileExists) {
                                                              // Add the PDF file only if it doesn't exist
                                                              ref
                                                                  .read(pdfFilesProvider
                                                                      .notifier)
                                                                  .addPdfFile(
                                                                      newPdfFile);
                                                            }

                                                            // Set the current PDF
                                                            if (ref
                                                                    .read(currentPdfProvider
                                                                        .notifier)
                                                                    .state ==
                                                                null) {
                                                              ref
                                                                  .read(currentPdfProvider
                                                                      .notifier)
                                                                  .state = newPdfFile;
                                                            }
                                                            ref
                                                                .read(currentPdfProvider
                                                                    .notifier)
                                                                .state = newPdfFile;
                                                          },
                                                          leading: Icon(Icons
                                                              .picture_as_pdf),
                                                          title: Text(
                                                              "Layer ${nonNullPdfFiles.indexOf(file) + 1}"),
                                                        ))
                                                    .toList(),
                                              );
                                            },
                                          );
                                        },
                                      )
                                    ]),
                              )
                            ],
                          ),
                        ),
                      )
                    : Container()
              ],
            ),
          ),
        );
      },
    );
  }
}
