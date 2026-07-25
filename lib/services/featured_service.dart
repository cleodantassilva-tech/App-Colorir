import '../data/sample_data.dart';

/// Define qual categoria premium fica gratuita neste mês, para
/// incentivar o usuário a experimentar mais conteúdo sem custo.
/// A cada mês, a categoria liberada muda automaticamente.
class FeaturedService {
  static String? categoriaGratisDoMes() {
    final premiumIds =
        categorias.where((c) => c.premium).map((c) => c.id).toList();
    if (premiumIds.isEmpty) return null;

    final agora = DateTime.now();
    final indice = (agora.year * 12 + agora.month) % premiumIds.length;
    return premiumIds[indice];
  }
}
