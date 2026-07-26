import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';

Future<PdfPageFormat?> escolherTamanhoPapel(BuildContext context) {
  return showDialog<PdfPageFormat>(
    context: context,
    builder: (context) => SimpleDialog(
      title: const Text('Tamanho do papel'),
      children: [
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context, PdfPageFormat.a4),
          child: const Text('A4'),
        ),
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context, PdfPageFormat.letter),
          child: const Text('Carta (Letter)'),
        ),
      ],
    ),
  );
}
