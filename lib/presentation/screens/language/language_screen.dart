import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geek_hackathon/presentation/providers/language_provider.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('言語設定')),
      body: ListView(
        children: [
          RadioListTile<Locale>(
            title: const Text('日本語'),
            value: const Locale('ja'),
            groupValue: currentLocale,
            onChanged: (Locale? value) {
              if (value != null) {
                ref.read(languageProvider.notifier).state = value;
              }
            },
          ),
          RadioListTile<Locale>(
            title: const Text('English'),
            value: const Locale('en'),
            groupValue: currentLocale,
            onChanged: (Locale? value) {
              if (value != null) {
                ref.read(languageProvider.notifier).state = value;
              }
            },
          ),
        ],
      ),
    );
  }
}
