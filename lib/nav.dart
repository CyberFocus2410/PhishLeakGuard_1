import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phishleak_guard/pages/landing_page.dart';
import 'package:phishleak_guard/pages/phish_shield_page.dart';
import 'package:phishleak_guard/pages/leak_watch_page.dart';
import 'package:phishleak_guard/pages/dashboard_page.dart';
import 'package:phishleak_guard/pages/spam_caller_page.dart';

/// GoRouter configuration for app navigation
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: LandingPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.phishShield,
        name: 'phish-shield',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: PhishShieldPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.leakWatch,
        name: 'leak-watch',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: LeakWatchPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: DashboardPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.spamCaller,
        name: 'spam-caller',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: SpamCallerPage(),
        ),
      ),
    ],
  );
}

/// Route path constants
class AppRoutes {
  static const String home = '/';
  static const String phishShield = '/phish-shield';
  static const String leakWatch = '/leak-watch';
  static const String dashboard = '/dashboard';
  static const String spamCaller = '/spam-caller';
}
