import 'package:flutter/material.dart';
import 'package:geek_hackathon/presentation/widgets/bottom_nav_bar_custom.dart';
import 'package:geek_hackathon/presentation/widgets/header.dart';

class BaseScaffold extends StatelessWidget {
  final Widget body;

  const BaseScaffold({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      body: Container(
        color: Colors.transparent, // ★これを明示しておく
        child: body,
      ),
      bottomNavigationBar: const BottomNavigationBarCustom(),
    );
  }
}
