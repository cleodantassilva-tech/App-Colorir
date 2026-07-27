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

    // Mantém a sua excelente trava de segurança para não travar o celular
    const larguraMaxima = 1000;
    final imagemRedimensionada = imagemOriginal.width > larguraMaxima
        ? img.copyResize(imagemOriginal, width: larguraMaxima)
        : imagemOriginal;

    final cinza = img.grayscale(imagemRedimensionada);

    // NOVA MATEMÁTICA: Desfoque agressivo (Raio 12)
    // Isso "embaça" texturas como asfalto, prédios e sujeiras antes de procurar as linhas.
    final suavizada = img.gaussianBlur(cinza, radius: 12);

    final bordas = img.sobel(suavizada);
    final invertida = img.invert(bordas);

    // NOVA MATEMÁTICA: Threshold mais rigoroso (0.85)
    // Força qualquer cinza claro a virar branco puro e foca só nos contornos reais.
    final resultado = img.luminanceThreshold(
      invertida,
      threshold: 0.85,
      outputColor: true,
    );

    return Uint8List.fromList(img.encodePng(resultado));
  }
}
