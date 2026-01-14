import 'package:flutter/material.dart';
import 'package:test_flutter_workflows/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter demo app',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 164, 164, 219)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
