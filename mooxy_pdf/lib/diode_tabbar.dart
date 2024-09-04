import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mooxy_pdf/diode_controller.dart' as diode_controller;
import 'package:mooxy_pdf/diode_controller.dart';
import 'package:mooxy_pdf/left_section.dart';
import 'package:mooxy_pdf/providers.dart';
import 'package:mooxy_pdf/right_section.dart';

class DiodeTabBar extends ConsumerStatefulWidget {
  const DiodeTabBar({super.key});

  @override
  ConsumerState createState() => _DiodeTabBarState();
}

class _DiodeTabBarState extends ConsumerState<DiodeTabBar> {
  final DiodeAppControllers _appControllers = DiodeAppControllers();
  late Future<BrandResponse> _brandsFuture;
  late List<Future<SubBrandResponse>> _subBrandFutures;
  late Map<String, Future<SubSubBrandResponse>> _subSubBrandFutures;

  @override
  void initState() {
    super.initState();
    _brandsFuture = _appControllers.getAllDirectSolutionsBrands();
    _subBrandFutures = [];
    _subSubBrandFutures = {};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BrandResponse>(
      future: _brandsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
          return Center(child: Text('No data available'));
        }

        final BrandResponse brands = snapshot.data!;

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
                  FutureBuilder<SubBrandResponse>(
                    future: _subBrandFutures[index],
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData ||
                          snapshot.data!.data.isEmpty) {
                        return Center(child: Text('No data available'));
                      }

                      final SubBrandResponse subBrands = snapshot.data!;

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
                                FutureBuilder<SubSubBrandResponse>(
                                  future: _subSubBrandFutures[subBrand.id],
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return Center(
                                          child:
                                              Text('Error: ${snapshot.error}'));
                                    } else if (!snapshot.hasData ||
                                        snapshot.data!.pdfData.isEmpty) {
                                      return Center(
                                          child: Text('No data available'));
                                    }

                                    final SubSubBrandResponse subSubBrands =
                                        snapshot.data!;

                                    return ListView.builder(
                                      primary: false,
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: subSubBrands.pdfData.length,
                                      itemBuilder: (context, innerSubIndex) {
                                        final pdfData =
                                            subSubBrands.pdfData[innerSubIndex];
                                        if (pdfData['file'] != null) {
                                          return ListTile(
                                            onTap: () {
                                              final newPdfFile =
                                                  diode_controller.PdfFile(
                                                      pdfUrl: AppStateProviders
                                                              .prifixUrl +
                                                          pdfData['file'],
                                                      pdfName: pdfData['name'],
                                                      pdfId: pdfData['_id']);

                                              // Add the PDF file only if it doesn't exist
                                              final pdfFiles =
                                                  ref.read(pdfFilesProvider);
                                              final pdfFileExists =
                                                  pdfFiles.any((file) =>
                                                      file.pdfId ==
                                                      newPdfFile.pdfId);

                                              if (!pdfFileExists) {
                                                ref
                                                    .read(pdfFilesProvider
                                                        .notifier)
                                                    .addPdfFile(newPdfFile);
                                              }

                                              ref
                                                  .read(currentPdfProvider
                                                      .notifier)
                                                  .state = newPdfFile;
                                            },
                                            leading: Icon(Icons.picture_as_pdf),
                                            title: Text(pdfData['name']),
                                          );
                                        } else {
                                          return SizedBox.shrink();
                                        }
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
