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

    // 1. Força tons de cinza logo no início
    final cinza = img.grayscale(imagemRedimensionada);

    // 2. Desfoque bem mais leve (Raio 2)
    // Isso evita que os traços fiquem grossos demais e salva os detalhes do rosto
    final suavizada = img.gaussianBlur(cinza, radius: 2);

    // 3. Detecta as bordas (agora mais finas)
    final bordas = img.sobel(suavizada);
    
    // 4. Inverte as cores (fundo vira branco, traços viram pretos)
    final invertida = img.invert(bordas);

    // 5. Threshold calibrado para traços mais finos
    final resultado = img.luminanceThreshold(
      invertida,
      threshold: 0.80, // Ajuste fino para não engrossar as linhas
    );

    // 6. GARANTIA: Aplica tons de cinza NOVAMENTE no final 
    // Isso mata completamente qualquer mancha azul ou colorida que tenha sobrado
    final resultadoFinal = img.grayscale(resultado);

    return Uint8List.fromList(img.encodePng(resultadoFinal));
  }
}
