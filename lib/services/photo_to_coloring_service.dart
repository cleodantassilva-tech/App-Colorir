import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Converte uma foto comum em um desenho de linhas, no estilo
/// "página para colorir", usando processamento local no dispositivo.
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

    // Reduzimos o desfoque (de 12 para 5). 
    // Assim o fundo perde a textura fina, mas o rosto e o corpo são preservados.
    final suavizada = img.gaussianBlur(cinza, radius: 5);

    final bordas = img.sobel(suavizada);
    final invertida = img.invert(bordas);

    // Reduzimos o limiar (de 0.85 para 0.78).
    // Isso ajuda a recuperar as linhas médias que tinham sido apagadas.
    final resultado = img.luminanceThreshold(
      invertida,
      threshold: 0.78,
      outputColor: true,
    );

    return Uint8List.fromList(img.encodePng(resultado));
  }
}
