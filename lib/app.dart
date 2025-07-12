import 'package:flutter/material.dart';
import 'package:geek_hackathon/presentation/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Hackathon App',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: router, // ← GoRouter をここで使う
    );
  }
}
