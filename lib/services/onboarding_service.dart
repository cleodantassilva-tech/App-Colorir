import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const _chave = 'onboarding_concluido';

  static Future<bool> jaViu() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_chave) ?? false;
  }

  static Future<void> marcarComoVisto() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chave, true);
  }
}
