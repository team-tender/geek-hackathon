import 'package:flutter/material.dart';
import 'package:geek_hackathon/data/models/destination.dart';

/// カードの表面（画像と地名）のUI
class CardFront extends StatelessWidget {
  const CardFront({super.key, required this.destination});

  final Destination destination;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey(false),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage(
            destination.imageUrl ??
                'https://via.placeholder.com/400x600?text=No+Image',
          ),
          fit: BoxFit.cover,
        ),
      ),
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.all(16),
      child: Text(
        destination.name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, blurRadius: 4)], // 文字を読みやすくする影
        ),
      ),
    );
  }
}
