import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mooxy_pdf/diode_controller.dart';
import 'package:mooxy_pdf/right_section.dart';

class CustomCheckbox extends ConsumerWidget {
  final PdfFile pdfFile;
  final ValueChanged<bool?> onChanged;
  const CustomCheckbox(
      {super.key, required this.pdfFile, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFiles = ref.watch(selectedPdfFilesProvider);
    final isSelected = selectedFiles.contains(pdfFile);

    return Checkbox(value: isSelected, onChanged: onChanged);
  }
}
