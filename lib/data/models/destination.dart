import 'package:flutter/foundation.dart';

@immutable
class Destination {
  const Destination({
    required this.name,
    required this.description,
    required this.access,
    this.imageUrl,
  });
  final String name;
  final String description;
  final String access;
  final String? imageUrl;

  // JSONからDestinationオブジェクトを生成するファクトリコンストラクタ
  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      name: json['name'] as String,
      description: json['description'] as String,
      access: json['access'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
