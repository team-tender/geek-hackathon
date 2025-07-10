import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geek_hackathon/data/repositories/mock_travel_repository.dart';

import 'package:geek_hackathon/presentation/screens/home/home_viewmodel.dart';

// APIの状態を表すenum
enum ApiStatus { initial, loading, success, error }

// 状態クラス
@immutable
class QuestionState {
  const QuestionState({
    this.status = ApiStatus.initial,
    this.question = 'PUSHボタンを押して診断を開始してください。',
    this.answers = const [],
    this.errorMessage,
  });

  final ApiStatus status;
  final String question;
  final List<String> answers;
  final String? errorMessage;

  QuestionState copyWith({
    ApiStatus? status,
    String? question,
    List<String>? answers,
    String? errorMessage,
  }) {
    return QuestionState(
      status: status ?? this.status,
      question: question ?? this.question,
      answers: answers ?? this.answers,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// StateNotifier
class QuestionViewModel extends StateNotifier<QuestionState> {
  // コンストラクタでRefを受け取る
  QuestionViewModel(this.ref) : super(const QuestionState());
  final Ref ref;

  // 最初の質問を取得
  Future<void> fetchFirstQuestion() async {
    state = const QuestionState(
      status: ApiStatus.loading,
      question: '質問を考えています...',
    );
    await _fetchQuestion();
  }

  // 回答を送信し、次の質問または最終結果を取得
  Future<void> submitAnswer(String question, String answer) async {
    final newAnswers = [...state.answers, 'Q: $question, A: $answer'];
    state = state.copyWith(
      status: ApiStatus.loading,
      answers: newAnswers,
      question: '次の質問を考えています...',
    );

    // 5回質問したら結果を出す
    if (newAnswers.length >= 5) {
      await _fetchDestinations();
    } else {
      await _fetchQuestion();
    }
  }

  // 質問を取得する内部メソッド
  Future<void> _fetchQuestion() async {
    try {
      // メソッド内でrepositoryを読み込む
      // final repository = ref.read(travelRepositoryProvider); // 本物API
      final repository = ref.read(mockTravelRepositoryProvider); // モックAPI
      final question = await repository.fetchQuestion(state.answers);
      state = state.copyWith(status: ApiStatus.success, question: question);
    } catch (e) {
      state = state.copyWith(
        status: ApiStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // 旅行先を取得する内部メソッド
  Future<void> _fetchDestinations() async {
    state = state.copyWith(
      status: ApiStatus.loading,
      question: 'おすすめの旅行先を診断中...',
    );
    try {
      // final repository = ref.read(travelRepositoryProvider); // 本物API
      final repository = ref.read(mockTravelRepositoryProvider); // モックAPI
      final destinationList = await repository.fetchDestinations(state.answers);

      // Home画面のProviderを更新
      ref.read(destinationListProvider.notifier).state = destinationList;
      // 状態を成功に戻す（画面遷移はUI側で行う）
      state = state.copyWith(status: ApiStatus.success);
    } catch (e) {
      // エラーを再スローしてUI側に失敗を伝える
      state = state.copyWith(
        status: ApiStatus.error,
        errorMessage: e.toString(),
      );
      throw Exception('旅行先の取得に失敗しました: $e');
    }
  }
}

// Provider (ViewModelをUIに提供)
// autoDisposeを追加して、画面が不要になったら自動でStateを破棄するようにします
final questionViewModelProvider =
    StateNotifierProvider.autoDispose<QuestionViewModel, QuestionState>(
      (ref) => QuestionViewModel(ref),
    );
