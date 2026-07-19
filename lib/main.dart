import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

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
      home: const HomeScreen(),
    );
  }
}
