// lib/presentation/providers/liked_destinations_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geek_hackathon/data/models/destination.dart';

class LikedDestinationsNotifier extends StateNotifier<List<Destination>> {
  LikedDestinationsNotifier() : super([]);

  void addDestination(Destination destination) {
    if (!state.contains(destination)) {
      state = [...state, destination];
    }
  }

  void clear() {
    state = [];
  }
}

final likedDestinationsProvider =
    StateNotifierProvider<LikedDestinationsNotifier, List<Destination>>(
        (ref) => LikedDestinationsNotifier());
