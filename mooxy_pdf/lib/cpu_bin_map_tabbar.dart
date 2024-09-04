import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mooxy_pdf/cpu_bin_map.dart';
import 'package:mooxy_pdf/left_section.dart';
import 'package:mooxy_pdf/providers.dart';
import 'package:mooxy_pdf/right_section.dart';

import 'diode_controller.dart' as diode_controller;

StateProvider<CpuBinMapResponse?> cpuBinMapProvider =
    StateProvider<CpuBinMapResponse?>((ref) {
  return null;
});

class CpuBinMapTabBar extends ConsumerStatefulWidget {
  const CpuBinMapTabBar({Key? key}) : super(key: key);

  @override
  ConsumerState<CpuBinMapTabBar> createState() => _CpuBinMapTabBarState();
}

class _CpuBinMapTabBarState extends ConsumerState<CpuBinMapTabBar> {
  final CpuBinMapController _controller = CpuBinMapController();
  late Future<CpuBrandResponse> _cpuBrandFuture;

  @override
  void initState() {
    super.initState();
    _cpuBrandFuture = _controller.getCpuBrand();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CpuBrandResponse>(
      future: _cpuBrandFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
          return Center(child: Text('No data available'));
        }

        final CpuBrandResponse cpuBrandResponse = snapshot.data!;

        return ListView.builder(
          itemCount: cpuBrandResponse.data.length,
          itemBuilder: (context, index) {
            final cpuBrand = cpuBrandResponse.data[index];
            return Padding(
              padding: const EdgeInsets.all(2.0),
              child: ExpansionTile(
                  title: Text(cpuBrand.name),
                  onExpansionChanged: (value) {
                    // if (value) {
                    //   final cpuBinMapFuture =
                    //       _controller.getCpuBinMap(cpuBrand.id);
                    //   ref.read(cpuBinMapProvider.notifier).state = null;
                    //   cpuBinMapFuture.then((value) {
                    //     ref.read(cpuBinMapProvider.notifier).state = value;
                    //   });
                    // }
                  },
                  children: [
                    FutureBuilder(
                      future: _controller.getCpuBinMap(cpuBrand.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Something went wrong'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.data.isEmpty) {
                          return Center(child: Text('No data available'));
                        }

                        final cpuBinMapResponse =
                            snapshot.data as CpuBinMapResponse;

                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: cpuBinMapResponse.data!.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(cpuBinMapResponse.data![index].name),
                              subtitle: Text(
                                  'Created: ${cpuBinMapResponse.data![index].createdAt.toLocal()}'),
                              trailing: Icon(Icons.picture_as_pdf),
                              onTap: () {
                                final newPdfFile = diode_controller.PdfFile(
                                    pdfUrl: AppStateProviders.prifixUrl +
                                        cpuBinMapResponse.data![index].pdfFile,
                                    pdfName:
                                        cpuBinMapResponse.data![index].name,
                                    pdfId: cpuBinMapResponse.data![index].id);

                                // Add the PDF file only if it doesn't exist
                                final pdfFiles = ref.read(pdfFilesProvider);
                                final pdfFileExists = pdfFiles.any(
                                    (file) => file.pdfId == newPdfFile.pdfId);

                                if (!pdfFileExists) {
                                  ref
                                      .read(pdfFilesProvider.notifier)
                                      .addPdfFile(newPdfFile);
                                }

                                ref.read(currentPdfProvider.notifier).state =
                                    newPdfFile;
                              },
                            );
                          },
                        );
                      },
                    )
                  ]),
            );
            // return ListTile(
            //   title: Text(cpuBinMap.name),
            //   subtitle: Text('Created: ${cpuBinMap.createdAt.toLocal()}'),
            //   trailing: Icon(Icons.picture_as_pdf),
            //   onTap: () {
            //     final newPdfFile = diode_controller.PdfFile(
            //         pdfUrl: AppStateProviders.prifixUrl + cpuBinMap.pdfFile,
            //         pdfName: cpuBinMap.name,
            //         pdfId: cpuBinMap.id);
            //
            //     // Add the PDF file only if it doesn't exist
            //     final pdfFiles = ref.read(pdfFilesProvider);
            //     final pdfFileExists =
            //         pdfFiles.any((file) => file.pdfId == newPdfFile.pdfId);
            //
            //     if (!pdfFileExists) {
            //       ref.read(pdfFilesProvider.notifier).addPdfFile(newPdfFile);
            //     }
            //
            //     ref.read(currentPdfProvider.notifier).state = newPdfFile;
            //   },
            // );
          },
        );
      },
    );
  }
}
