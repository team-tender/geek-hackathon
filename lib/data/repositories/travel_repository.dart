import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:geek_hackathon/data/models/destination.dart';

// --- Repositoryのインターフェース ---
abstract class TravelRepository {
  Future<String> fetchQuestion(List<String> answers);
  Future<List<Destination>> fetchDestinations(List<String> answers);
}

// --- Repositoryの実装クラス ---
class TravelRepositoryImpl implements TravelRepository {
  // ★TODO: プロジェクトIDはご自身のものに書き換えてください
  final String _baseUrl = "http://10.0.2.2:5001/tender-13fe2/us-central1";

  @override
  Future<String> fetchQuestion(List<String> answers) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/getTravelQuestion'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'data': {'answers': answers},
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return data['question'] as String;
    } else {
      throw Exception('質問の取得に失敗しました。Status Code: ${response.statusCode}');
    }
  }

  @override
  Future<List<Destination>> fetchDestinations(List<String> answers) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/getTravelDestination'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'data': {'answers': answers},
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      final List<dynamic> destinationListJson = data['destinations'];

      return destinationListJson
          .map((json) => Destination.fromJson(json))
          .toList();
    } else {
      throw Exception('旅行先の取得に失敗しました。Status Code: ${response.statusCode}');
    }
  }
}

// --- RepositoryのProvider ---
final travelRepositoryProvider = Provider<TravelRepository>((ref) {
  return TravelRepositoryImpl();
});
