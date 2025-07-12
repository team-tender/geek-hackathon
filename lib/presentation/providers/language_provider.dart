import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 言語設定を管理するProvider
final languageProvider = StateProvider<Locale>((ref) => const Locale('ja')); //
