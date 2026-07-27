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

    // 1. Tons de cinza
    final cinza = img.grayscale(imagemRedimensionada);

    // 2. Desfoque médio (Raio 3)
    // Borra a textura da roupa e da pele, mas preserva os olhos
    final suavizada = img.gaussianBlur(cinza, radius: 3);

    // 3. Detecta as bordas
    final bordas = img.sobel(suavizada);
    
    // 4. Inverte as cores
    final invertida = img.invert(bordas);

    // 5. Threshold muito rigoroso (0.88)
    // Força as linhas fracas (sujeira da roupa) a virarem branco puro.
    // Só sobrevive o que for contorno bem escuro.
    final resultado = img.luminanceThreshold(
      invertida,
      threshold: 0.88, 
      outputColor: true,
    );

    // 6. Garante o preto e branco absoluto (remove manchas azuis)
    final resultadoFinal = img.grayscale(resultado);

    return Uint8List.fromList(img.encodePng(resultadoFinal));
  }
}
