import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geek_hackathon/data/models/destination.dart';

// ホーム画面の旅行先リストを管理するProvider
final destinationListProvider = StateProvider<List<Destination>>((ref) => []);

//Favorite用のProvider
final favoriteDestinationProvider = StateProvider<List<Destination>>((ref) => []);
