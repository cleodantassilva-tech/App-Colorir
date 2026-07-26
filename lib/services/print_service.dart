import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrintService {
  static Future<void> imprimirDesenho({
    required String caminhoAsset,
    required String nomeDocumento,
    PdfPageFormat? formato,
  }) async {
    final bytes = await rootBundle.load(caminhoAsset);
    final dadosPdf = bytes.buffer.asUint8List();

    await Printing.layoutPdf(
      name: nomeDocumento,
      format: formato ?? PdfPageFormat.a4,
      onLayout: (format) async => dadosPdf,
    );
  }

  static Future<void> imprimirImagem({
    required Uint8List bytesImagem,
    required String nomeDocumento,
    PdfPageFormat? formato,
  }) async {
    final pageFormat = formato ?? PdfPageFormat.a4;
    final documento = pw.Document();
    final imagemPdf = pw.MemoryImage(bytesImagem);

    documento.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (context) => pw.Center(
          child: pw.Image(imagemPdf, fit: pw.BoxFit.contain),
        ),
      ),
    );

    final dadosPdf = await documento.save();

    await Printing.layoutPdf(
      name: nomeDocumento,
      format: pageFormat,
      onLayout: (format) async => dadosPdf,
    );
  }

  static Future<void> imprimirVarios({
    required List<String> caminhosAssets,
    required String nomeDocumento,
    PdfPageFormat? formato,
  }) async {
    final pageFormat = formato ?? PdfPageFormat.a4;
    final documento = pw.Document();

    for (final caminho in caminhosAssets) {
      final bytes = await rootBundle.load(caminho);
      final dadosPdfOriginal = bytes.buffer.asUint8List();

      final paginasRasterizadas = Printing.raster(dadosPdfOriginal, dpi: 150);

      await for (final pagina in paginasRasterizadas) {
        final pngBytes = await pagina.toPng();
        final imagemPdf = pw.MemoryImage(pngBytes);

        documento.addPage(
          pw.Page(
            pageFormat: pageFormat,
            build: (context) => pw.Center(
              child: pw.Image(imagemPdf, fit: pw.BoxFit.contain),
            ),
          ),
        );
      }
    }

    final dadosPdf = await documento.save();

    await Printing.layoutPdf(
      name: nomeDocumento,
      format: pageFormat,
      onLayout: (format) async => dadosPdf,
    );
  }

  static Future<void> visualizarDesenho({
    required String caminhoAsset,
    required String nomeDocumento,
  }) async {
    final bytes = await rootBundle.load(caminhoAsset);
    final dadosPdf = bytes.buffer.asUint8List();

    await Printing.sharePdf(
      bytes: dadosPdf,
      filename: '$nomeDocumento.pdf',
    );
  }
}
