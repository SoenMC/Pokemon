import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/detail_page.dart';
import '../../presentation/pages/favorites_page.dart';
import '../../presentation/pages/sightings_page.dart';
import '../../presentation/pages/settings_page.dart';

//define screens
GoRouter buildRouter() => GoRouter(  //Wich screen open
  routes: [
    GoRoute(path: '/', builder: (c, s) => const HomePage()), //path and widget to display
    GoRoute(path: '/detail/:id', builder: (c, s) { //path and widget to display
      final id = int.tryParse(s.pathParameters['id'] ?? '') ?? 0;
      return DetailPage(id: id);
    }),
    GoRoute(path: '/favorites', builder: (c, s) => const FavoritesPage()), //path and widget to display
    GoRoute(path: '/sightings', builder: (c, s) => const SightingsPage()), //path and widget to display
    GoRoute(path: '/settings', builder: (c, s) => const SettingsPage()), //path and widget to display
  ],
);