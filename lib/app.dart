import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geek_hackathon/presentation/providers/language_provider.dart';
import 'package:geek_hackathon/presentation/routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageProvider);

    return MaterialApp.router(
      title: 'Hackathon App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFFFCA96),
      ),
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // サポートするロケールを追加
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('ja', ''), // Japanese
        Locale('ko', ''), // Korean
        Locale('zh', ''), // Chinese
        Locale('es', ''), // Spanish
        Locale('fr', ''), // French
      ],
      locale: locale,
    );
  }
}
