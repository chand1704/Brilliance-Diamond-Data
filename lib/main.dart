import 'package:brilliance_diamond_data/diamonds_details_pages.dart';
import 'package:flutter/material.dart';

import 'gmss_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Brilliance Diamond Store Data',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF009688)),
      ),
      onGenerateRoute: (settings) {
        if (settings.name != null && settings.name!.startsWith('/details')) {
          final uri = Uri.parse(settings.name!);
          final stoneId = uri.queryParameters['id'];
          final shape = uri.queryParameters['shape'];
          return PageRouteBuilder(
            settings: settings,
            transitionDuration: Duration.zero,
            pageBuilder: (_, __, ___) => DiamondDetailScreen(
              stoneId: stoneId,
              shape: shape,
              stone: null,
              isFavorite: false,
              onFavoriteToggle: (val) {},
            ),
          );
        }
        return null;
      },
      home: GmssScreen(),
    );
  }
}
