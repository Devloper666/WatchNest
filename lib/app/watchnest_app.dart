import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../screens/animated_splash_screen.dart';

class WatchNestApp extends StatelessWidget {
  const WatchNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WatchNest',
      themeMode: ThemeMode.dark,
      theme: AppTheme.darkTheme,
      home: const AnimatedSplashScreen(),
    );
  }
}
