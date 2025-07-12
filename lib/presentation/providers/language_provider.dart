import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// サポートする言語のリスト
final supportedLocales = [
  const Locale('ja'), // 日本語
  const Locale('en'), // 英語
  const Locale('ko'), // 韓国語
  const Locale('zh'), // 中国語
  const Locale('es'), // スペイン語
  const Locale('fr'), // フランス語
];

// 言語設定を管理するProvider
final languageProvider = StateProvider<Locale>((ref) {
  // デフォルト言語を日本語に設定
  return supportedLocales.first;
});
