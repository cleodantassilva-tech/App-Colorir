import 'package:shared_preferences/shared_preferences.dart';

/// Guarda quais desenhos o usuário já imprimiu, para exibir um
/// indicador visual (ex: "já impresso") nas telas do app.
class PrintHistoryService {
  static const _chave = 'desenhos_impressos';

  static Future<Set<String>> obterImpressos() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_chave) ?? []).toSet();
  }

  static Future<void> marcarComoImpresso(String desenhoId) async {
    final prefs = await SharedPreferences.getInstance();
    final impressos = (prefs.getStringList(_chave) ?? []).toSet();
    impressos.add(desenhoId);
    await prefs.setStringList(_chave, impressos.toList());
  }

  static Future<bool> foiImpresso(String desenhoId) async {
    final impressos = await obterImpressos();
    return impressos.contains(desenhoId);
  }
}
