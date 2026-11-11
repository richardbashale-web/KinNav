import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'presentation/pages/screens.dart';
import 'presentation/theme.dart';

class KinNavApp extends StatelessWidget {
  const KinNavApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
        GoRoute(path: '/routes', builder: (_, __) => const RouteResultsScreen()),
        GoRoute(path: '/navigation', builder: (_, __) => const NavigationScreen()),
        GoRoute(path: '/alerts', builder: (_, __) => const AlertsScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      ],
    );
    return MaterialApp.router(
      title: 'KinNav',
      theme: buildTheme(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
