import 'package:flutter/services.dart' show rootBundle;
import 'package:printing/printing.dart';

/// Serviço responsável por enviar o desenho para impressão.
///
/// O pacote `printing` abre o diálogo NATIVO de impressão do Android,
/// que já lista automaticamente impressoras conectadas via:
///   - Wi-Fi (mesma rede)
///   - Wi-Fi Direct
///   - Bluetooth (se o plugin do fabricante estiver instalado, ex: Mopria, HP, Epson)
///
/// Não é necessário implementar nenhuma lógica de pareamento ou conexão:
/// isso é responsabilidade do sistema operacional e do plugin de impressora.
class PrintService {
  /// Imprime um arquivo PDF a partir do caminho de asset informado.
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

  /// Alternativa: gera uma prévia de impressão (útil para o botão
  /// "Visualizar antes de imprimir").
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
