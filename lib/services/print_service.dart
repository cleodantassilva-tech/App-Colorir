import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrintService {
  // 1. A NOSSA FUNÇÃO NOVA (Exatamente como você mandou, com o nome da criança)
  static Future<void> imprimirImagem({
    required Uint8List bytesImagem,
    required String nomeDocumento,
    String? nomeCrianca, 
  }) async {
    final pdf = pw.Document();
    final image = pw.MemoryImage(bytesImagem);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              if (nomeCrianca != null && nomeCrianca.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 20, top: 20),
                  child: pw.Text(
                    'Colorido por: $nomeCrianca',
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                
              pw.Expanded(
                child: pw.Center(
                  child: pw.Image(image, fit: pw.BoxFit.contain),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: nomeDocumento,
    );
  }

  // 2. A FUNÇÃO ANTIGA RESTAURADA (Para o app parar de dar erro e compilar)
  static Future<void> imprimirDesenho(String caminhoAsset) async {
    final pdf = pw.Document();
    
    final ByteData imageBytes = await rootBundle.load(caminhoAsset);
    final Uint8List imageData = imageBytes.buffer.asUint8List();
    final image = pw.MemoryImage(imageData);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(image, fit: pw.BoxFit.contain),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Desenho_para_Colorir',
    );
  }
}
