import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geek_hackathon/presentation/providers/language_provider.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  // サポートする言語のリストを定義
  static const Map<String, String> supportedLanguages = {
    'ja': '日本語',
    'en': 'English',
    'ko': '한국어',
    'zh': '中文',
    'es': 'Español',
    'fr': 'Français',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 現在選択されている言語コードを取得
    final currentLocale = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('言語設定')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('アプリの表示言語を選択してください', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            // DropdownButtonを追加
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Locale>(
                  isExpanded: true,
                  // 現在の言語を値として設定
                  value: currentLocale,
                  // ドロップダウンのアイテムを生成
                  items: supportedLanguages.entries.map((entry) {
                    return DropdownMenuItem<Locale>(
                      value: Locale(entry.key),
                      child: Text(entry.value),
                    );
                  }).toList(),
                  // 言語が変更されたときのアクション
                  onChanged: (Locale? newLocale) {
                    if (newLocale != null) {
                      // Providerの状態を更新して言語を切り替え
                      ref.read(languageProvider.notifier).state = newLocale;
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
