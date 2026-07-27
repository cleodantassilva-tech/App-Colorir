import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrintService {
  static Future<void> imprimirImagem({
    required Uint8List bytesImagem,
    required String nomeDocumento,
    String? nomeCrianca, // NOVO: Recebe o nome digitado lá na tela
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
              // NOVO: Se o usuário digitou um nome, cria o título no topo!
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
                
              // O desenho centralizado ocupando o resto do espaço
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
}
