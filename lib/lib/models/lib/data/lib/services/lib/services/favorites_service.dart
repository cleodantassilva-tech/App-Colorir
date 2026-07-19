import 'package:shared_preferences/shared_preferences.dart';

/// Gerencia a lista de desenhos favoritados pelo usuário,
/// persistida localmente no dispositivo.
class FavoritesService {
  static const _chave = 'favoritos_ids';

  static Future<Set<String>> obterFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_chave) ?? []).toSet();
  }

  static Future<void> alternarFavorito(String desenhoId) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritos = (prefs.getStringList(_chave) ?? []).toSet();

    if (favoritos.contains(desenhoId)) {
      favoritos.remove(desenhoId);
    } else {
      favoritos.add(desenhoId);
    }

    await prefs.setStringList(_chave, favoritos.toList());
  }

  static Future<bool> ehFavorito(String desenhoId) async {
    final favoritos = await obterFavoritos();
    return favoritos.contains(desenhoId);
  }
}
