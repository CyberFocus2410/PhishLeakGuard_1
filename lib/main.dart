import 'package:flutter/material.dart';
import 'theme.dart';
import 'nav.dart';

/// Main entry point for the PhishLeak Guard application
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PhishShield Guard',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark, // Default to dark mode for cybersecurity aesthetic

      // Router configuration
      routerConfig: AppRouter.router,
    );
  }
}
