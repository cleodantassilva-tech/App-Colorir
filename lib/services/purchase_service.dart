import 'package:shared_preferences/shared_preferences.dart';

class PurchaseService {
  static const _chaveCompraUnica = 'desbloqueado_tudo';
  static const _chaveAssinatura = 'assinatura_ativa';

  static Future<bool> estaDesbloqueado() async {
    final prefs = await SharedPreferences.getInstance();
    final compraUnica = prefs.getBool(_chaveCompraUnica) ?? false;
    final assinatura = prefs.getBool(_chaveAssinatura) ?? false;
    return compraUnica || assinatura;
  }

  static Future<void> desbloquearTudo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chaveCompraUnica, true);
  }

  static Future<bool> assinaturaAtiva() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_chaveAssinatura) ?? false;
  }

  static Future<void> ativarAssinatura() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chaveAssinatura, true);
  }

  static Future<void> cancelarAssinatura() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chaveAssinatura, false);
  }
}
