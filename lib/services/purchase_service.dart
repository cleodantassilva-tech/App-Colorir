import 'package:shared_preferences/shared_preferences.dart';

/// Controla se o usuário já desbloqueou todas as categorias premium.
///
/// Por enquanto, o desbloqueio é salvo localmente (sem cobrança real).
/// Quando você integrar um sistema de pagamento de verdade
/// (ex: in_app_purchase), troque `desbloquearTudo()` para só
/// salvar `true` depois que a compra for confirmada pela loja.
class PurchaseService {
  static const _chave = 'desbloqueado_tudo';

  static Future<bool> estaDesbloqueado() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_chave) ?? false;
  }

  static Future<void> desbloquearTudo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chave, true);
  }
}
