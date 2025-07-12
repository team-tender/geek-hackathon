import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:geek_hackathon/data/models/destination.dart';
import 'package:geek_hackathon/presentation/screens/home/home_viewmodel.dart';

enum ApiStatus { initial, loading, success, error }

class Destination {
  final String name;
  final String? imageUrl;
  final String description;

  Destination({required this.name, this.imageUrl, required this.description});
}

class QuestionState {
  final String question;
  final ApiStatus status;
  final String? errorMessage;
  final Destination? destination;

  const QuestionState({
    this.question = '',
    this.status = ApiStatus.initial,
    this.errorMessage,
    this.destination,
  });

  QuestionState copyWith({
    String? question,
    ApiStatus? status,
    ValueGetter<String?>? errorMessage,
    ValueGetter<Destination?>? destination,
  }) {
    return QuestionState(
      question: question ?? this.question,
      status: status ?? this.status,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      destination: destination != null ? destination() : this.destination,
    );
  }
}

class QuestionViewModel extends StateNotifier<QuestionState> {
  final Ref ref;
  final List<QuestionState> _previousStates = [];

  QuestionViewModel(this.ref) : super(const QuestionState());

  bool get canUndo => _previousStates.isNotEmpty;

  void reset() {
    _previousStates.clear();
    state = const QuestionState();
  }

  Future<void> fetchFirstQuestion() async {
    _previousStates.clear();
    state = state.copyWith(
      status: ApiStatus.loading,
      question: '最初の質問を準備中です...',
      destination: () => null,
    );
    await Future.delayed(const Duration(seconds: 1));
    try {
      state = state.copyWith(
        status: ApiStatus.success,
        question: 'あなたはアウトドア派ですか？',
      );
    } catch (e) {
      state = state.copyWith(
        status: ApiStatus.error,
        errorMessage: () => e.toString(),
      );
    }
  }

  Future<void> submitAnswer(String question, String answer) async {
    _saveState();
    state = state.copyWith(
      status: ApiStatus.loading,
      question: '次の質問を考えています...',
    );
    await Future.delayed(const Duration(seconds: 1));

    try {
      if (question == 'あなたはアウトドア派ですか？') {
        if (answer == 'はい') {
          state = state.copyWith(
            status: ApiStatus.success,
            question: '山と海、どちらが好きですか？',
          );
        } else {
          state = state.copyWith(
            status: ApiStatus.success,
            question: '美術館巡りは好きですか？',
          );
        }
      } else if (question == '山と海、どちらが好きですか？') {
        final destination = Destination(
          name: answer == '山' ? '富士山' : '沖縄の海',
          imageUrl: answer == '山'
              ? 'https://cdn.pixabay.com/photo/2016/11/29/05/45/mount-fuji-1867117_1280.jpg'
              : 'https://cdn.pixabay.com/photo/2017/01/20/00/30/okinawa-1993796_1280.jpg',
          description: answer == '山'
              ? '日本一の山、富士山での壮大なハイキングをお楽しみください。'
              : '美しいビーチと透き通った海が広がる沖縄でリラックスしましょう。',
        );
        ref.read(destinationListProvider.notifier).state = [destination];
        state = state.copyWith(
          status: ApiStatus.success,
          destination: () => destination,
        );
      } else if (question == '美術館巡りは好きですか？') {
        final destination = Destination(
          name: answer == 'はい' ? '国立新美術館' : 'お家で映画鑑賞',
          imageUrl: answer == 'はい'
              ? 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/The_National_Art_Center%2C_Tokyo_01.jpg/1280px-The_National_Art_Center%2C_Tokyo_01.jpg'
              : 'https://cdn.pixabay.com/photo/2014/09/27/13/44/notebook-463533_1280.jpg',
          description: answer == 'はい'
              ? '東京にある国立新美術館で、現代アートの世界に触れてみませんか。'
              : '家でのんびりと好きな映画を観るのが最高のリフレッシュです。',
        );
        ref.read(destinationListProvider.notifier).state = [destination];
        state = state.copyWith(
          status: ApiStatus.success,
          destination: () => destination,
        );
      } else {
        state = state.copyWith(
          status: ApiStatus.success,
          question: '診断が完了しました！',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: ApiStatus.error,
        errorMessage: () => e.toString(),
      );
    }
  }

  void _saveState() {
    _previousStates.add(state);
  }

  void undo() {
    if (_previousStates.isNotEmpty) {
      state = _previousStates.removeLast();
    }
  }
}

final questionViewModelProvider =
    StateNotifierProvider<QuestionViewModel, QuestionState>(
  (ref) => QuestionViewModel(ref),
);
