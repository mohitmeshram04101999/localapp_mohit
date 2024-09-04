import 'package:flutter/material.dart';
import 'package:mooxy_pdf/diode_controller.dart';

class TabModel {
  List<PdfFile> pdfFiles;
  List<Widget> tabs;
  TabModel({required this.pdfFiles, required this.tabs});

  TabModel.fromJson(Map<String, dynamic> json)
      : pdfFiles = List<PdfFile>.from(
            json['pdfFiles'].map((x) => PdfFile.fromJson(x))),
        tabs = List<Widget>.from(json['tabs'].map((x) => x));

  Map<String, dynamic> toJson() => {
        'pdfFiles': pdfFiles.map((x) => x.toJson()).toList(),
        'tabs': tabs.map((x) => x).toList(),
      };
}
