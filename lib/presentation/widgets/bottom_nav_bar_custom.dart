import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavigationBarCustom extends StatelessWidget {
  const BottomNavigationBarCustom({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // ナビゲーションバー背景
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      red: 0,
                      green: 0,
                      blue: 0,
                      alpha: 26, // 0.1 × 255 ≒ 26
                    ),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ホームボタン
                  IconButton(
                    icon: const Icon(Icons.home),
                    onPressed: () => context.go('/home'),
                  ),
                  // 三本線メニューボタン
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        builder: (_) => const BottomSheetMenu(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // 中央の PUSH ボタン
          Positioned(
            bottom: 12,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                elevation: 4,
              ),
              onPressed: () => context.go('/question'),
              child: const Text(
                'PUSH',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 仮の BottomSheetMenu（後で分離してファイル化）
class BottomSheetMenu extends StatelessWidget {
  const BottomSheetMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('PROFILE'),
            onTap: () {
              context.pop(); // モーダルを閉じる
              context.go('/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('FAVORITE'),
            onTap: () {
              context.pop();
              context.go('/favorite');
            },
          ),
        ],
      ),
    );
  }
}
