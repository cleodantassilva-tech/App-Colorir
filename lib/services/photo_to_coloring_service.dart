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

    const larguraMaxima = 1000;
    final imagemRedimensionada = imagemOriginal.width > larguraMaxima
        ? img.copyResize(imagemOriginal, width: larguraMaxima)
        : imagemOriginal;

    final cinza = img.grayscale(imagemRedimensionada);

    // Suaviza ANTES de detectar bordas, para reduzir ruído/textura
    // (grama, tecido, cascalho) e deixar os traços mais limpos.
    final suavizada = img.gaussianBlur(cinza, radius: 3);

    final bordas = img.sobel(suavizada);
    final invertida = img.invert(bordas);

    // Mantém só as bordas mais fortes como linhas pretas,
    // eliminando o ruído fraco de fundo.
    final resultado = img.luminanceThreshold(
      invertida,
      threshold: 0.82,
      outputColor: true,
    );

    return Uint8List.fromList(img.encodePng(resultado));
  }
}
