import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';

class PrintService {
  static Future<void> imprimirDesenho({
    required String caminhoAsset,
    required String nomeDocumento,
  }) async {
    final bytes = await rootBundle.load(caminhoAsset);
    final dadosPdf = bytes.buffer.asUint8List();

    await Printing.layoutPdf(
      name: nomeDocumento,
      onLayout: (format) async => dadosPdf,
    );
  }

  /// Imprime uma imagem que está em memória (ex: gerada pela conversão
  /// de foto para desenho), sem precisar que ela esteja nos assets do app.
  static Future<void> imprimirImagem({
    required Uint8List bytesImagem,
    required String nomeDocumento,
  }) async {
    final documento = pw.Document();
    final imagemPdf = pw.MemoryImage(bytesImagem);

    documento.addPage(
      pw.Page(
        build: (context) => pw.Center(
          child: pw.Image(imagemPdf, fit: pw.BoxFit.contain),
        ),
      ),
    );

    final dadosPdf = await documento.save();

    await Printing.layoutPdf(
      name: nomeDocumento,
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
