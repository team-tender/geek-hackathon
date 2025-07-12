import 'package:flutter/material.dart';
import 'package:geek_hackathon/presentation/screens/favorite/favorite_screen.dart';
import 'package:geek_hackathon/presentation/screens/home/home_screen.dart';
import 'package:geek_hackathon/presentation/screens/profile/profile_screen.dart';
import 'package:geek_hackathon/presentation/screens/question/question_screen.dart';
import 'package:geek_hackathon/presentation/widgets/bottom_nav_bar_custom.dart';
import 'package:geek_hackathon/presentation/widgets/header.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        // 👇 共通のヘッダーとナビゲーションバー
        return SafeArea(
          child: Scaffold(
            appBar: const Header(),
            body: child,
            bottomNavigationBar: const BottomNavigationBarCustom(),
          ),
        );
      },
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/question',
          builder: (context, state) => const QuestionScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/favorite',
          builder: (context, state) => const FavoriteScreen(),
        ),
      ],
    ),
  ],
);
