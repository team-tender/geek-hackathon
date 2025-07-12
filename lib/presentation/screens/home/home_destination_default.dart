// lib/data/mock/default_destinations.dart
import 'package:geek_hackathon/data/models/destination.dart';

final defaultDestinations = [
  Destination(
    name: '京都',
    description: '伝統と現代が融合する古都。',
    access: '新幹線で2時間',
    imageUrl: 'https://source.unsplash.com/featured/?kyoto',
  ),
  Destination(
    name: '沖縄',
    description: '青い海と白い砂浜が広がる楽園。',
    access: '飛行機で3時間',
    imageUrl: 'https://source.unsplash.com/featured/?okinawa',
  ),
  Destination(
    name: '北海道',
    description: '大自然と新鮮な海の幸を楽しめる。',
    access: '飛行機で1時間半',
    imageUrl: 'https://source.unsplash.com/featured/?hokkaido',
  ),
];
