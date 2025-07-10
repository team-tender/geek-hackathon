import 'package:geek_hackathon/data/models/destination.dart';
import 'package:geek_hackathon/data/repositories/travel_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TravelRepositoryインターフェースを実装したモッククラス
class MockTravelRepositoryImpl implements TravelRepository {
  @override
  Future<String> fetchQuestion(List<String> answers) async {
    // ネットワーク通信があるように見せかけるため、1秒待つ
    await Future.delayed(const Duration(seconds: 1));

    // 用意した質問リスト
    const mockQuestions = [
      '賑やかな都会の雰囲気が好きですか？',
      '歴史的な街並みや文化に触れたいですか？',
      '美しい自然や景色に癒されたいですか？',
      '美味しいものを食べることが旅行の主な目的ですか？',
      '温泉でゆっくりとリラックスしたいですか？',
    ];

    // まだ答えていない質問を返す
    if (answers.length < mockQuestions.length) {
      return mockQuestions[answers.length];
    } else {
      return "すべての質問が終わりました。";
    }
  }

  @override
  Future<List<Destination>> fetchDestinations(List<String> answers) async {
    // ネットワーク通信があるように見せかけるため、2秒待つ
    await Future.delayed(const Duration(seconds: 2));

    // モックの旅行先データリストを返す
    return const [
      Destination(
        name: '北海道',
        description:
            '広大な大地と豊かな自然が魅力の北海道。新鮮な海の幸や美味しい乳製品、美しい景色が訪れる人々を魅了します。四季折々のアクティビティも楽しめます。',
        access: '東京から飛行機で約1時間半。新千歳空港から札幌市内へは電車やバスで約40分です。',
        imageUrl:
            'https://images.unsplash.com/photo-1589192412845-18c644158548',
      ),
      Destination(
        name: '京都',
        description:
            '日本の古都、京都。歴史ある寺社仏閣が立ち並び、美しい庭園や伝統的な町並みが魅力です。四季折々の風情を感じながら、心安らぐひとときを過ごせます。',
        access: '東京駅から新幹線「のぞみ」で約2時間15分。京都駅からは市内の主要観光地へバスや電車でアクセスできます。',
        imageUrl:
            'https://images.unsplash.com/photo-1533283281864-a6111a1975e5',
      ),
      Destination(
        name: '沖縄',
        description:
            '美しいエメラルドグリーンの海と白い砂浜が広がる南国の楽園。独自の琉球文化や歴史、温暖な気候の中でのんびりとした時間を過ごすことができます。',
        access: '東京から飛行機で約2時間半〜3時間。那覇空港からモノレールやバスで各地へ移動できます。',
        imageUrl:
            'https://images.unsplash.com/photo-1519046904884-53103b34b206',
      ),
    ];
  }
}

// --- モックリポジトリ用のProvider ---
// このProviderを差し替えることで、アプリ全体がモックデータを使うようになります。
final mockTravelRepositoryProvider = Provider<TravelRepository>((ref) {
  return MockTravelRepositoryImpl();
});
