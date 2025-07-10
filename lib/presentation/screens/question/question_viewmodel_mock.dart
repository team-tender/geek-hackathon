// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// // httpパッケージは不要になるためコメントアウトまたは削除します
// // import 'package:http/http.dart' as http;
//
// // APIの状態を表すenum
// enum ApiStatus { initial, loading, success, error }
//
// // 旅行先の情報を保持するクラス
// @immutable
// class Destination {
//   const Destination({
//     required this.name,
//     required this.description,
//     this.imageUrl,
//   });
//   final String name;
//   final String description;
//   final String? imageUrl;
// }
//
// // 状態クラス
// @immutable
// class QuestionState {
//   const QuestionState({
//     this.status = ApiStatus.initial,
//     this.question = 'PUSHボタンを押して診断を開始してください。',
//     this.answers = const [],
//     this.destination,
//     this.errorMessage,
//   });
//
//   final ApiStatus status;
//   final String question;
//   final List<String> answers;
//   final Destination? destination;
//   final String? errorMessage;
//
//   QuestionState copyWith({
//     ApiStatus? status,
//     String? question,
//     List<String>? answers,
//     Destination? destination,
//     String? errorMessage,
//   }) {
//     return QuestionState(
//       status: status ?? this.status,
//       question: question ?? this.question,
//       answers: answers ?? this.answers,
//       destination: destination ?? this.destination,
//       errorMessage: errorMessage ?? this.errorMessage,
//     );
//   }
// }
//
// // StateNotifier
// class QuestionViewModel extends StateNotifier<QuestionState> {
//   QuestionViewModel() : super(const QuestionState());
//
//   // ▼▼▼ ここから下がモック処理 ▼▼▼
//
//   // 最初の質問を取得
//   Future<void> fetchFirstQuestion() async {
//     state = const QuestionState(
//       status: ApiStatus.loading,
//       question: '質問を考えています...',
//     );
//     await _fetchQuestion();
//   }
//
//   // 回答を送信し、次の質問または最終結果を取得
//   Future<void> submitAnswer(String question, String answer) async {
//     final newAnswers = [...state.answers, 'Q: $question, A: $answer'];
//     state = state.copyWith(
//       status: ApiStatus.loading,
//       answers: newAnswers,
//       question: '次の質問を考えています...',
//       destination: null, // 結果をリセット
//     );
//
//     // 5回質問したら結果を出す
//     if (newAnswers.length >= 5) {
//       await _fetchDestination();
//     } else {
//       await _fetchQuestion();
//     }
//   }
//
//   // --- 質問を取得する内部メソッド (モック版) ---
//   Future<void> _fetchQuestion() async {
//     // ネットワーク通信をシミュレート
//     await Future.delayed(const Duration(seconds: 1));
//
//     // 用意した質問リスト
//     const mockQuestions = [
//       '賑やかな都会の雰囲気が好きですか？',
//       '歴史的な街並みや文化に触れたいですか？',
//       '美しい自然や景色に癒されたいですか？',
//       '美味しいものを食べることが旅行の主な目的ですか？',
//       '温泉でゆっくりとリラックスしたいですか？',
//     ];
//
//     // 現在の回答数に応じて次の質問を出す
//     final nextQuestion = mockQuestions[state.answers.length];
//
//     state = state.copyWith(status: ApiStatus.success, question: nextQuestion);
//   }
//
//   // --- 旅行先を取得する内部メソッド (モック版) ---
//   Future<void> _fetchDestination() async {
//     // ネットワーク通信をシミュレート
//     state = state.copyWith(
//       status: ApiStatus.loading,
//       question: 'おすすめの旅行先を診断中...',
//     );
//     await Future.delayed(const Duration(seconds: 2));
//
//     // モックの旅行先データ
//     const mockDestination = Destination(
//       name: '京都',
//       description:
//           '日本の古都、京都。歴史ある寺社仏閣が立ち並び、美しい庭園や伝統的な町並みが魅力です。四季折々の風情を感じながら、心安らぐひとときを過ごせます。',
//       imageUrl:
//           'https://images.unsplash.com/photo-1533283281864-a6111a1975e5', // Unsplashのサンプル画像URL
//     );
//
//     state = state.copyWith(
//       status: ApiStatus.success,
//       destination: mockDestination,
//     );
//   }
// }
//
// // Provider
// final questionViewModelProvider =
//     StateNotifierProvider<QuestionViewModel, QuestionState>(
//       (ref) => QuestionViewModel(),
//     );
