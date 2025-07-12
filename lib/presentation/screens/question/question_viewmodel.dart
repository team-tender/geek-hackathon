import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geek_hackathon/data/repositories/mock_travel_repository.dart';
import 'package:geek_hackathon/data/repositories/travel_repository.dart';
import 'package:geek_hackathon/presentation/screens/home/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:geek_hackathon/data/models/destination.dart';



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
    this.destination,
  });

  final ApiStatus status;
  final String question;
  final List<String> answers;
  final String? errorMessage;

  final Destination? destination;

  QuestionState copyWith({
    ApiStatus? status,
    String? question,
    List<String>? answers,
    String? errorMessage,
    Destination? destination,
  }) {
    return QuestionState(
      status: status ?? this.status,
      question: question ?? this.question,
      answers: answers ?? this.answers,
      errorMessage: errorMessage ?? this.errorMessage,
      destination: destination ?? this.destination,
    );
  }
}


// StateNotifier
class QuestionViewModel extends StateNotifier<QuestionState> {
  final TravelRepository _travelRepository;
  final Ref ref;
  final List<QuestionState> _previousStates = [];
  final List<String> _answers = [];

  List<String> get answers => _answers;

  QuestionViewModel(this.ref)
      : _travelRepository = ref.read(mockTravelRepositoryProvider),
        super(const QuestionState());

  bool get canUndo => _previousStates.isNotEmpty;

  void reset() {
    _previousStates.clear();
    _answers.clear();
    state = const QuestionState();
  }

  Future<void> fetchFirstQuestion() async {
    _previousStates.clear();
    _answers.clear();

    state = const QuestionState(
      status: ApiStatus.loading,
      question: '質問を考えています...',
    );
    await _fetchQuestion();
  }

  Future<void> submitAnswer(String question, String answer) async {
    _saveState();

    _answers.add(answer);

    state = state.copyWith(
      status: ApiStatus.loading,
      answers: [..._answers],
      question: '次の質問を考えています...',
    );

    if (_answers.length >= 5) {
      await _fetchDestinations();
    } else {
      await _fetchQuestion();
    }
  }

  void _saveState() {
    _previousStates.add(state);
  }

  void undo() {
    if (_previousStates.isNotEmpty && _answers.isNotEmpty) {
      state = _previousStates.removeLast();
      _answers.removeLast();
    }
  }

  Future<void> _fetchQuestion() async {
    try {
      final question = await _travelRepository.fetchQuestion(_answers);
      state = state.copyWith(
        status: ApiStatus.success,
        question: question,
        answers: [..._answers],
      );
    } catch (e) {
      state = state.copyWith(
        status: ApiStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _fetchDestinations() async {
    state = state.copyWith(
      status: ApiStatus.loading,
      question: 'おすすめの旅行先を診断中...',
    );
    try {
      final destinationList = await _travelRepository.fetchDestinations(_answers); // ✅ destinationList を定義
      ref.read(destinationListProvider.notifier).state = destinationList;

      state = state.copyWith(
        status: ApiStatus.success,
        answers: [..._answers],
        destination: destinationList.isNotEmpty ? destinationList.first : null, // ✅ ここで使う
      );
    } catch (e) {
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
    StateNotifierProvider<QuestionViewModel, QuestionState>((ref) {
      return QuestionViewModel(ref);
    });
