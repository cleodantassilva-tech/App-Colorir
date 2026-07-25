import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Converte uma foto comum em um desenho de linhas, no estilo
/// "página para colorir", usando processamento local no dispositivo
/// (a foto nunca sai do celular, nem é enviada para nenhum servidor).
class PhotoToColoringService {
  static Uint8List converterParaDesenho(Uint8List bytesOriginais) {
    final imagemOriginal = img.decodeImage(bytesOriginais);
    if (imagemOriginal == null) {
      throw Exception('Não foi possível ler essa imagem.');
    }

    const larguraMaxima = 1200;
    final imagemRedimensionada = imagemOriginal.width > larguraMaxima
        ? img.copyResize(imagemOriginal, width: larguraMaxima)
        : imagemOriginal;

    final cinza = img.grayscale(imagemRedimensionada);
    final bordas = img.sobel(cinza);
    final invertida = img.invert(bordas);
    final resultado = img.adjustColor(
      invertida,
      contrast: 1.6,
      brightness: 1.05,
    );

    return Uint8List.fromList(img.encodePng(resultado));
  }
}
