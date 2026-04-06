import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/view/login_screen.dart';

void main() {
  runApp(const RumankaApp());
}

class RumankaApp extends StatelessWidget {
  const RumankaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rumanka',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const LoginScreen(),
    );
  }
}
