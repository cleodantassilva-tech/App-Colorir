import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/onboarding_service.dart';

void main() {
  runApp(const AppColorir());
}

class AppColorir extends StatelessWidget {
  const AppColorir({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desenhos para Colorir',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepOrange,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const _TelaInicialRoteador(),
    );
  }
}

class _TelaInicialRoteador extends StatelessWidget {
  const _TelaInicialRoteador();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: OnboardingService.jaViu(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data! ? const HomeScreen() : const OnboardingScreen();
      },
    );
  }
}
