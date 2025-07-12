import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavigationBarCustom extends StatefulWidget {
  const BottomNavigationBarCustom({super.key});

  @override
  State<BottomNavigationBarCustom> createState() =>
      _BottomNavigationBarCustomState();
}

class _BottomNavigationBarCustomState extends State<BottomNavigationBarCustom>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  Future<void> _onTendPressed() async {
    await _controller.forward();
    await Future.delayed(const Duration(milliseconds: 50));
    await _controller.reverse();
    // contextがまだ有効かを確認してから画面遷移を行う
    if (mounted) {
      context.go('/question');
    }
    // ▲▲▲ 修正点1 ▲▲▲
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
                  BoxShadow(color: Colors.black.withAlpha(26), blurRadius: 4),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.home),
                    iconSize: 32,
                    onPressed: () => context.go('/home'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu),
                    iconSize: 32,
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => const BottomSheetMenu(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // 中央のTENDボタン（アニメーション＋押下時色反転）
          Positioned(
            bottom: 10,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: ElevatedButton(
                // MaterialStateProperty を WidgetStateProperty に変更
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>((
                    states,
                  ) {
                    if (states.contains(WidgetState.pressed)) {
                      return Colors.white; // 押してるとき：白背景
                    }
                    return Colors.deepOrange; // 通常：オレンジ背景
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith<Color>((
                    states,
                  ) {
                    if (states.contains(WidgetState.pressed)) {
                      return Colors.deepOrange; // 押してるとき：オレンジ文字
                    }
                    return Colors.white; // 通常：白文字
                  }),
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  elevation: WidgetStateProperty.all(4),
                  minimumSize: WidgetStateProperty.all(const Size(250, 55)),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(
                        color: Colors.deepOrange,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                onPressed: _onTendPressed,
                child: const Text(
                  'TEND',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// モーダルメニュー（PROFILE, FAVORITE, LANGUAGE）
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
              context.pop();
              context.go('/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('FAVORITE'),
            onTap: () {
              context.pop();
              context.go('/favorite');
            },
          ),
          ListTile(
            // アイコンを language に変更
            leading: const Icon(Icons.language),
            title: const Text('LANGUAGE'),
            onTap: () {
              context.pop();
              context.go('/language');
            },
          ),
        ],
      ),
    );
  }
}
