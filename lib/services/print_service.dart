import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrintService {
  // 1. Função nova para imprimir foto convertida com o nome da criança
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

  // 2. Corrigido para aceitar o parâmetro nomeado (caminhoAsset: ...)
  static Future<void> imprimirDesenho({String? caminhoAsset}) async {
    final pdf = pw.Document();
    
    if (caminhoAsset != null && caminhoAsset.isNotEmpty) {
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
    }

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Desenho_para_Colorir',
    );
  }

  // 3. Corrigido para tornar o argumento opcional, evitando o erro de "0 given"
  static Future<void> imprimirVarios([List<String>? caminhosAssets]) async {
    final pdf = pw.Document();

    if (caminhosAssets != null && caminhosAssets.isNotEmpty) {
      for (var caminho in caminhosAssets) {
        final ByteData imageBytes = await rootBundle.load(caminho);
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
      }
    } else {
      // Página de segurança caso a galeria chame a função vazia
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Text("Nenhum desenho recebido para impressao."),
            );
          },
        ),
      );
    }

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Desenhos_Colorir',
    );
  }
}
