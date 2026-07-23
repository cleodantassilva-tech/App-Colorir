import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
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
  static Map<String, dynamic>? _manifestCache;

  static Future<Map<String, dynamic>> _carregarManifest() async {
    if (_manifestCache != null) return _manifestCache!;
    final conteudo = await rootBundle.loadString('AssetManifest.json');
    _manifestCache = json.decode(conteudo) as Map<String, dynamic>;
    return _manifestCache!;
  }

  static Future<List<Desenho>> listarPorCategoria(String categoriaId) async {
    final manifest = await _carregarManifest();
    final prefixo = 'assets/categorias/$categoriaId/';

    final pdfs = manifest.keys
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
