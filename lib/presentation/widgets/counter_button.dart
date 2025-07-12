import 'package:flutter/material.dart';

class CounterButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CounterButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, child: const Text('Increment'));
  }
}
