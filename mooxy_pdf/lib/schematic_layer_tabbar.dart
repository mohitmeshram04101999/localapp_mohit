import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mooxy_pdf/diode_controller.dart' as diode_controller;
import 'package:mooxy_pdf/left_section.dart';
import 'package:mooxy_pdf/providers.dart';
import 'package:mooxy_pdf/right_section.dart';
import 'package:mooxy_pdf/schematic_layer_controller.dart' as layers;

class SchematicLayerTabBar extends ConsumerStatefulWidget {
  const SchematicLayerTabBar({super.key});

  @override
  ConsumerState createState() => _SchematicLayerTabBarState();
}

class _SchematicLayerTabBarState extends ConsumerState<SchematicLayerTabBar> {
  final layers.SchematicLayerAppControllers _appControllers =
      layers.SchematicLayerAppControllers();
  late Future<layers.BrandResponse> _brandsFuture;
  late List<Future<layers.SubBrandResponse>> _subBrandFutures;
  late Map<String, Future<layers.SchematicPdfResponse>> _subSubBrandFutures;

  @override
  void initState() {
    super.initState();
    _brandsFuture = _appControllers.getAllSchematicLayerBrands();
    _subBrandFutures = [];
    _subSubBrandFutures = {};
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

        return ListView.builder(
          primary: false,
          itemCount: brands.data.length,
          itemBuilder: (context, index) {
            final brand = brands.data[index];

            // Initialize the future for sub-brands only once
            _subBrandFutures
                .add(_appControllers.getAllSubBrandsByPBrand(brand.id ?? ''));

            return Padding(
              padding: const EdgeInsets.all(2.0),
              child: ExpansionTile(
                title: Text('${brand.name}'),
                leading: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                    AppStateProviders.prifixUrl + brand.icon,
                  ),
                ),
                children: [
                  FutureBuilder<layers.SubBrandResponse>(
                    future: _subBrandFutures[index],
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Something went wrong!'));
                      } else if (!snapshot.hasData ||
                          snapshot.data!.data.isEmpty) {
                        return Center(child: Text('No data available'));
                      }

                      final layers.SubBrandResponse subBrands = snapshot.data!;

                      return ListView.builder(
                        primary: false,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: subBrands.data.length,
                        itemBuilder: (context, innerIndex) {
                          final subBrand = subBrands.data[innerIndex];

                          // Initialize the future for sub-sub-brands only once
                          if (!_subSubBrandFutures.containsKey(subBrand.id)) {
                            _subSubBrandFutures[subBrand.id!] = _appControllers
                                .getAllSubSubBrandsByPBrand(subBrand.id!);
                          }

                          return Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: ExpansionTile(
                              title: Text('${subBrand.name}'),
                              leading: CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider(
                                  AppStateProviders.prifixUrl + subBrand.icon,
                                ),
                              ),
                              children: [
                                FutureBuilder<layers.SchematicPdfResponse>(
                                  future: _subSubBrandFutures[subBrand.id],
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return Center(
                                          child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('Something went wrong!'),
                                      ));
                                    } else if (!snapshot.hasData ||
                                        snapshot.data!.data.isEmpty) {
                                      return Center(
                                          child: Text('No data available'));
                                    }

                                    final layers.SchematicPdfResponse
                                        schematicPdfs = snapshot.data!;
                                    log(schematicPdfs.data.length.toString());

                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: schematicPdfs.data.length,
                                      itemBuilder: (context, innerSubIndex) {
                                        layers.SchematicPdf pdfData =
                                            schematicPdfs.data[innerSubIndex];

                                        // Filter out null entries and create a list of non-null PDF files
                                        List<String> nonNullPdfFiles = pdfData
                                            .pdfFile
                                            .where((file) => file != null)
                                            .cast<String>()
                                            .toList();

                                        // If there are no non-null PDF files, return an empty container
                                        if (nonNullPdfFiles.isEmpty) {
                                          return Container();
                                        }
                                        return Column(
                                          children: nonNullPdfFiles.map((file) {
                                            log(nonNullPdfFiles[innerSubIndex]
                                                    .indexOf(file)
                                                    .toString() +
                                                "  " +
                                                file);
                                            return ListTile(
                                              onTap: () {
                                                final newPdfFile =
                                                    diode_controller.PdfFile(
                                                        pdfUrl:
                                                            AppStateProviders
                                                                    .prifixUrl +
                                                                file,
                                                        pdfName: file
                                                            .split('/')
                                                            .last,
                                                        pdfId:
                                                            '${pdfData.id}_${file.split('/').last}' // Create a unique ID for each file
                                                        );

                                                // Check if the PDF file already exists in the provider
                                                final pdfFiles =
                                                    ref.read(pdfFilesProvider);
                                                final pdfFileExists = pdfFiles
                                                    .any((existingFile) =>
                                                        existingFile.pdfId ==
                                                        newPdfFile.pdfId);

                                                if (!pdfFileExists) {
                                                  // Add the PDF file only if it doesn't exist
                                                  ref
                                                      .read(pdfFilesProvider
                                                          .notifier)
                                                      .addPdfFile(newPdfFile);
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
                                              leading:
                                                  Icon(Icons.picture_as_pdf),
                                              title: nonNullPdfFiles[innerSubIndex]
                                                          .indexOf(file) ==
                                                      0
                                                  ? Text('Schematic')
                                                  : nonNullPdfFiles[innerSubIndex]
                                                                  .indexOf(
                                                                      file) *
                                                              -1 ==
                                                          1
                                                      ? Text("PCB Layout")
                                                      : nonNullPdfFiles[innerSubIndex]
                                                                      .indexOf(
                                                                          file) *
                                                                  -1 ==
                                                              2
                                                          ? Text(
                                                              "Sub PCB Layout")
                                                          : nonNullPdfFiles[innerSubIndex]
                                                                          .indexOf(
                                                                              file) *
                                                                      -1 ==
                                                                  3
                                                              ? Text(
                                                                  "Sub PCB Schematic")
                                                              : nonNullPdfFiles[innerSubIndex].indexOf(file) *
                                                                          -1 ==
                                                                      4
                                                                  ? Text(
                                                                      "Block Diagram")
                                                                  : Text(
                                                                      "Schematic Pdf ${nonNullPdfFiles[innerSubIndex].indexOf(file)}"),
                                            );
                                          }).toList(),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
