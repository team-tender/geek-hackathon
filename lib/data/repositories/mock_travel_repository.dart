import 'package:geek_hackathon/data/models/destination.dart';
import 'package:geek_hackathon/data/repositories/travel_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TravelRepositoryインターフェースを実装したモッククラス
class MockTravelRepositoryImpl implements TravelRepository {
  // ▼▼▼ 修正 ▼▼▼
  @override
  Future<String> fetchQuestion(
    List<String> answers,
    String languageCode,
  ) async {
    // ネットワーク通信があるように見せかけるため、1秒待つ
    await Future.delayed(const Duration(seconds: 1));

    // 言語に応じた質問リストを用意
    final mockQuestions = {
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
    };

    // 言語コードに対応する質問リストを取得（なければ日本語をデフォルトに）
    final questions = mockQuestions[languageCode] ?? mockQuestions['ja']!;

    if (answers.length < questions.length) {
      return questions[answers.length];
    } else {
      return languageCode == 'ja'
          ? "すべての質問が終わりました。"
          : "All questions are finished.";
    }
  }

  // ▼▼▼ 修正 ▼▼▼
  @override
  Future<List<Destination>> fetchDestinations(
    List<String> answers,
    String languageCode,
  ) async {
    // ネットワーク通信があるように見せかけるため、2秒待つ
    await Future.delayed(const Duration(seconds: 2));

    // 言語に応じた旅行先データを用意
    final mockDestinations = {
      'ja': const [
        Destination(
          name: '箱根',
          description: '温泉、美術館、芦ノ湖など、自然とアートが融合した人気の観光地。都心からのアクセスも良好です。',
          access: '新宿駅からロマンスカーで約85分。',
          imageUrl:
              'https://media.istockphoto.com/id/839688614/ja/%E3%82%B9%E3%83%88%E3%83%83%E3%82%AF%E3%83%95%E3%82%A9%E3%83%88/%E5%B1%B1%E8%97%A4%E8%8A%A6%E3%83%8E%E6%B9%96%E7%AE%B1%E6%A0%B9%E3%81%AE%E5%AF%BA%E9%99%A2.webp?a=1&b=1&s=612x612&w=0&k=20&c=5nmUpPpjrVCl98-_J3_JNR79u43E1ZeHQRjmMLWCYuY=',
        ),
        Destination(
          name: '軽井沢',
          description: '避暑地として有名な高原リゾート。アウトレットでのショッピングや、美しい自然の中でのサイクリングが楽しめます。',
          access: '東京駅から新幹線で約70分。',
          imageUrl:
              'https://media.istockphoto.com/id/1402910619/ja/%E3%82%B9%E3%83%88%E3%83%83%E3%82%AF%E3%83%95%E3%82%A9%E3%83%88/%E7%A7%8B%E3%81%A8%E5%B0%8F%E5%B7%9D%E8%BB%BD%E4%BA%95%E6%B2%A2.webp?a=1&b=1&s=612x612&w=0&k=20&c=pU-ksYzd0mDgN4nIN25IyG95gOdJo1iesCoor3xJCks=',
        ),
        Destination(
          name: '別府温泉',
          description: '日本一の源泉数と湧出量を誇る温泉郷。「地獄めぐり」で様々な色の温泉を見て回るのが人気です。',
          access: '大分空港からバスで約40分。',
          imageUrl:
              'https://media.istockphoto.com/id/1223763181/ja/%E3%82%B9%E3%83%88%E3%83%83%E3%82%AF%E3%83%95%E3%82%A9%E3%83%88/%E3%82%BD%E3%82%A6%E3%83%AB%E9%9F%93%E5%9B%BDn%E3%82%BF%E3%83%AF%E3%83%BC%E3%81%AE%E3%81%82%E3%82%8B%E8%A1%97%E3%81%A8%E3%83%96%E3%83%81%E3%83%A7%E3%83%B3%E3%83%8F%E3%83%8E%E3%82%AF%E6%9D%91%E3%81%AE%E7%9C%BA%E3%82%81%E3%82%B9%E3%83%88%E3%83%83%E3%82%AF%E5%86%99%E7%9C%9F.webp?a=1&b=1&s=612x612&w=0&k=20&c=46zyCb-g5GHAHGWO60TkxvtvnOp1tEzjckvD7KfTABg=',
        ),
        Destination(
          name: '伊勢志摩',
          description: '伊勢神宮や夫婦岩など、神聖な場所が点在。リアス式海岸の美しい景色や、新鮮な海の幸も魅力です。',
          access: '名古屋駅から近鉄特急で約80分。',
          imageUrl:
              'https://media.istockphoto.com/id/1223763181/ja/%E3%82%B9%E3%83%88%E3%83%83%E3%82%AF%E3%83%95%E3%82%A9%E3%83%88/%E3%82%BD%E3%82%A6%E3%83%AB%E9%9F%93%E5%9B%BDn%E3%82%BF%E3%83%AF%E3%83%BC%E3%81%AE%E3%81%82%E3%82%8B%E8%A1%97%E3%81%A8%E3%83%96%E3%83%81%E3%83%A7%E3%83%B3%E3%83%8F%E3%83%8E%E3%82%AF%E6%9D%91%E3%81%AE%E7%9C%BA%E3%82%81%E3%82%B9%E3%83%88%E3%83%83%E3%82%AF%E5%86%99%E7%9C%9F.webp?a=1&b=1&s=612x612&w=0&k=20&c=46zyCb-g5GHAHGWO60TkxvtvnOp1tEzjckvD7KfTABg=',
        ),
        Destination(
          name: '金沢',
          description: '加賀百万石の城下町の風情が残る街。兼六園やひがし茶屋街、21世紀美術館など見どころが豊富です。',
          access: '東京駅から新幹線で約2時間半。',
          imageUrl:
              'https://plus.unsplash.com/premium_photo-1690957591806-95a2b81b1075?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8a2FuYXphd2F8ZW58MHx8MHx8fDA%3D',
        ),
      ],
      'en': const [
        Destination(
          name: 'Hakone',
          description:
              'A popular tourist spot where nature and art merge, featuring hot springs, museums, and Lake Ashi. Good access from central Tokyo.',
          access: 'About 85 minutes by Romancecar from Shinjuku Station.',
          imageUrl:
              'https://media.istockphoto.com/id/839688614/ja/%E3%82%B9%E3%83%88%E3%83%83%E3%82%AF%E3%83%95%E3%82%A9%E3%83%88/%E5%B1%B1%E8%97%A4%E8%8A%A6%E3%83%8E%E6%B9%96%E7%AE%B1%E6%A0%B9%E3%81%AE%E5%AF%BA%E9%99%A2.webp?a=1&b=1&s=612x612&w=0&k=20&c=5nmUpPpjrVCl98-_J3_JNR79u43E1ZeHQRjmMLWCYuY=',
        ),
        Destination(
          name: 'Karuizawa',
          description:
              'A famous highland resort known as a summer retreat. Enjoy shopping at the outlet mall and cycling in the beautiful nature.',
          access: 'About 70 minutes by Shinkansen from Tokyo Station.',
          imageUrl:
              'https://media.istockphoto.com/id/1402910619/ja/%E3%82%B9%E3%83%88%E3%83%83%E3%82%AF%E3%83%95%E3%82%A9%E3%83%88/%E7%A7%8B%E3%81%A8%E5%B0%8F%E5%B7%9D%E8%BB%BD%E4%BA%95%E6%B2%A2.webp?a=1&b=1&s=612x612&w=0&k=20&c=pU-ksYzd0mDgN4nIN25IyG95gOdJo1iesCoor3xJCks=',
        ),
        Destination(
          name: 'Beppu Onsen',
          description:
              'A hot spring area boasting the largest number of springs and volume of water in Japan. The "Hell Tour" to see various colored hot springs is popular.',
          access: 'About 40 minutes by bus from Oita Airport.',
          imageUrl:
              'https://media.istockphoto.com/id/1223763181/ja/%E3%82%B9%E3%83%88%E3%83%83%E3%82%AF%E3%83%95%E3%82%A9%E3%83%88/%E3%82%BD%E3%82%A6%E3%83%AB%E9%9F%93%E5%9B%BDn%E3%82%BF%E3%83%AF%E3%83%BC%E3%81%AE%E3%81%82%E3%82%8B%E8%A1%97%E3%81%A8%E3%83%96%E3%83%81%E3%83%A7%E3%83%B3%E3%83%8F%E3%83%8E%E3%82%AF%E6%9D%91%E3%81%AE%E7%9C%BA%E3%82%81%E3%82%B9%E3%83%88%E3%83%83%E3%82%AF%E5%86%99%E7%9C%9F.webp?a=1&b=1&s=612x612&w=0&k=20&c=46zyCb-g5GHAHGWO60TkxvtvnOp1tEzjckvD7KfTABg=',
        ),
        Destination(
          name: 'Ise-Shima',
          description:
              'A sacred area with spots like Ise Grand Shrine and Meoto Iwa. The beautiful scenery of the ria coast and fresh seafood are also attractions.',
          access:
              'About 80 minutes by Kintetsu limited express from Nagoya Station.',
          imageUrl:
              'https://media.istockphoto.com/id/1223763181/ja/%E3%82%B9%E3%83%88%E3%83%83%E3%82%AF%E3%83%95%E3%82%A9%E3%83%88/%E3%82%BD%E3%82%A6%E3%83%AB%E9%9F%93%E5%9B%BDn%E3%82%BF%E3%83%AF%E3%83%BC%E3%81%AE%E3%81%82%E3%82%8B%E8%A1%97%E3%81%A8%E3%83%96%E3%83%81%E3%83%A7%E3%83%B3%E3%83%8F%E3%83%8E%E3%82%AF%E6%9D%91%E3%81%AE%E7%9C%BA%E3%82%81%E3%82%B9%E3%83%88%E3%83%83%E3%82%AF%E5%86%99%E7%9C%9F.webp?a=1&b=1&s=612x612&w=0&k=20&c=46zyCb-g5GHAHGWO60TkxvtvnOp1tEzjckvD7KfTABg=',
        ),
        Destination(
          name: 'Kanazawa',
          description:
              'A city that retains the atmosphere of the Kaga Hyakumangoku castle town. It has many attractions such as Kenrokuen, Higashi Chaya District, and the 21st Century Museum of Contemporary Art.',
          access: 'About 2.5 hours by Shinkansen from Tokyo Station.',
          imageUrl:
              'https://plus.unsplash.com/premium_photo-1690957591806-95a2b81b1075?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8a2FuYXphd2F8ZW58MHx8MHx8fDA%3D',
        ),
      ],
    };

    // 言語コードに対応するデータを返す（なければ日本語をデフォルトに）
    return mockDestinations[languageCode] ?? mockDestinations['ja']!;
  }
}

// --- モックリポジトリ用のProvider ---
// このProviderを差し替えることで、アプリ全体がモックデータを使うようになります。
final mockTravelRepositoryProvider = Provider<TravelRepository>((ref) {
  return MockTravelRepositoryImpl();
});
