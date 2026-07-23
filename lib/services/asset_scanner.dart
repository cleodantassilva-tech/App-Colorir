import 'package:flutter/services.dart' show rootBundle, AssetManifest;
import '../models/desenho.dart';

/// Detecta automaticamente os desenhos disponíveis em cada categoria,
/// lendo os arquivos que foram incluídos nos assets do app.
///
/// Convenção de nomes esperada dentro de cada pasta de categoria:
///   <id_categoria>_01.pdf
///   <id_categoria>_01_thumb.png
///   <id_categoria>_02.pdf
///   <id_categoria>_02_thumb.png
///   ...
class AssetScanner {
  static List<String>? _assetsCache;

  static Future<List<String>> _carregarListaAssets() async {
    if (_assetsCache != null) return _assetsCache!;
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    _assetsCache = manifest.listAssets();
    return _assetsCache!;
  }

  static Future<List<Desenho>> listarPorCategoria(String categoriaId) async {
    final todosAssets = await _carregarListaAssets();
    final prefixo = 'assets/categorias/$categoriaId/';

    final pdfs = todosAssets
        .where((chave) => chave.startsWith(prefixo) && chave.endsWith('.pdf'))
        .toList()
      ..sort();

    return pdfs.map((caminhoPdf) {
      final nomeArquivo = caminhoPdf.split('/').last;
      final idBase = nomeArquivo.replaceAll('.pdf', '');
      final thumbnail = '$prefixo${idBase}_thumb.png';

      return Desenho(
        id: idBase,
        titulo: _gerarTitulo(idBase),
        categoria: categoriaId,
        caminhoArquivo: caminhoPdf,
        thumbnail: thumbnail,
      );
    }).toList();
  }

  static Future<List<Desenho>> listarTodos(List<String> categoriaIds) async {
    final resultado = <Desenho>[];
    for (final id in categoriaIds) {
      resultado.addAll(await listarPorCategoria(id));
    }
    return resultado;
  }

  static String _gerarTitulo(String idBase) {
    final numero = RegExp(r'(\d+)$').firstMatch(idBase)?.group(1);
    return numero == null ? 'Desenho' : 'Desenho $numero';
  }
}
