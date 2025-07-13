import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geek_hackathon/data/models/destination.dart';
import 'package:geek_hackathon/data/repositories/travel_repository.dart';

// TravelRepositoryインターフェースを実装したモッククラス
class MockTravelRepositoryImpl implements TravelRepository {
  // --- モックデータ定義 ---
  // 質問のモックデータ
  static const Map<String, List<String>> _mockQuestions = {
    'ja': [
      '賑やかな都会の雰囲気が好きですか？',
      '歴史的な街並みや文化に触れたいですか？',
      '美しい自然や景色に癒されたいですか？',
      '美味しいものを食べることが旅行の主な目的ですか？',
      '温泉でゆっくりとリラックスしたいですか？',
    ],
    'en': [
      'Do you like the lively atmosphere of a big city?',
      'Do you want to experience historical townscapes and culture?',
      'Do you want to be healed by beautiful nature and scenery?',
      'Is eating delicious food the main purpose of your trip?',
      'Do you want to relax in a hot spring?',
    ],
    // 他言語の質問もここに追加可能
  };

  // 旅行先のモックデータ
  static const Map<String, List<Destination>> _mockDestinations = {
    'ja': [
      Destination(
        name: '箱根',
        description: '温泉、美術館、芦ノ湖など、自然とアートが融合した人気の観光地。都心からのアクセスも良好です。',
        access: '新宿駅からロマンスカーで約85分。',
        imageUrl: 'https://images.unsplash.com/photo-1547366963-3113708555a5',
      ),
      Destination(
        name: '軽井沢',
        description: '避暑地として有名な高原リゾート。アウトレットでのショッピングや、美しい自然の中でのサイクリングが楽しめます。',
        access: '東京駅から新幹線で約70分。',
        imageUrl:
            'https://images.unsplash.com/photo-1593032464789-2a21644e591c',
      ),
      Destination(
        name: '別府温泉',
        description: '日本一の源泉数と湧出量を誇る温泉郷。「地獄めぐり」で様々な色の温泉を見て回るのが人気です。',
        access: '大分空港からバスで約40分。',
        imageUrl:
            'https://images.unsplash.com/photo-1618394595856-9e5c43d83769',
      ),
      Destination(
        name: '伊勢志摩',
        description: '伊勢神宮や夫婦岩など、神聖な場所が点在。リアス式海岸の美しい景色や、新鮮な海の幸も魅力です。',
        access: '名古屋駅から近鉄特急で約80分。',
        imageUrl:
            'https://images.unsplash.com/photo-1588820083516-a39151528485',
      ),
      Destination(
        name: '金沢',
        description: '加賀百万石の城下町の風情が残る街。兼六園やひがし茶屋街、21世紀美術館など見どころが豊富です。',
        access: '東京駅から新幹線で約2時間半。',
        imageUrl:
            'https://images.unsplash.com/photo-1582772598383-3563a6285435',
      ),
    ],
    'en': [
      Destination(
        name: 'Hakone',
        description:
            'A popular tourist spot where nature and art merge, featuring hot springs, museums, and Lake Ashi. Good access from central Tokyo.',
        access: 'About 85 minutes by Romancecar from Shinjuku Station.',
        imageUrl: 'https://images.unsplash.com/photo-1547366963-3113708555a5',
      ),
      Destination(
        name: 'Karuizawa',
        description:
            'A famous highland resort known as a summer retreat. Enjoy shopping at the outlet mall and cycling in the beautiful nature.',
        access: 'About 70 minutes by Shinkansen from Tokyo Station.',
        imageUrl:
            'https://images.unsplash.com/photo-1593032464789-2a21644e591c',
      ),
      Destination(
        name: 'Beppu Onsen',
        description:
            'A hot spring area boasting the largest number of springs and volume of water in Japan. The "Hell Tour" is popular.',
        access: 'About 40 minutes by bus from Oita Airport.',
        imageUrl:
            'https://images.unsplash.com/photo-1618394595856-9e5c43d83769',
      ),
      Destination(
        name: 'Ise-Shima',
        description:
            'A sacred area with spots like Ise Grand Shrine and Meoto Iwa. The beautiful scenery of the ria coast is also an attraction.',
        access:
            'About 80 minutes by Kintetsu limited express from Nagoya Station.',
        imageUrl:
            'https://images.unsplash.com/photo-1588820083516-a39151528485',
      ),
      Destination(
        name: 'Kanazawa',
        description:
            'A city that retains the atmosphere of a castle town. It has many attractions such as Kenrokuen and Higashi Chaya District.',
        access: 'About 2.5 hours by Shinkansen from Tokyo Station.',
        imageUrl:
            'https://images.unsplash.com/photo-1582772598383-3563a6285435',
      ),
    ],
  };

  @override
  Future<String> fetchQuestion(
    List<String> answers,
    String languageCode,
  ) async {
    await Future.delayed(const Duration(seconds: 1)); // API通信を模倣

    final questions = _mockQuestions[languageCode] ?? _mockQuestions['ja']!;
    if (answers.length < questions.length) {
      return questions[answers.length];
    }
    return languageCode == 'ja'
        ? "すべての質問が終わりました。"
        : "All questions are finished.";
  }

  @override
  Future<List<Destination>> fetchDestinations(
    List<String> answers,
    String languageCode,
  ) async {
    await Future.delayed(const Duration(seconds: 2)); // API通信を模倣

    // 本来は回答(answers)に基づいてロジックを組むが、モックでは固定のリストを返す
    final destinations =
        _mockDestinations[languageCode] ?? _mockDestinations['ja']!;
    return destinations;
  }

  @override
  Future<List<Destination>> fetchRandomDestinations(String languageCode) async {
    await Future.delayed(const Duration(seconds: 2)); // API通信を模倣

    final destinations =
        _mockDestinations[languageCode] ?? _mockDestinations['ja']!;
    // 実際にはランダムにシャッフルする
    final shuffledList = List<Destination>.from(destinations)
      ..shuffle(Random());
    return shuffledList;
  }
}

// --- モックリポジトリ用のProvider ---
// このProviderを差し替えることで、アプリ全体がモックデータを使うようになります。
// 例えば、main.dartで以下のように上書きできます。
//
// ProviderScope(
//   overrides: [
//     travelRepositoryProvider.overrideWith((ref) => MockTravelRepositoryImpl()),
//   ],
//   child: const MyApp(),
// )
final mockTravelRepositoryProvider = Provider<TravelRepository>((ref) {
  return MockTravelRepositoryImpl();
});
