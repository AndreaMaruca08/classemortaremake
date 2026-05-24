import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'auth/authWrapper.dart';

/// Entry point of the application.
void main() {
  runApp(const EgonApplication());
}

class EgonApplication extends StatelessWidget {
  const EgonApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      home: const AuthWrapper(isPreviousYear: false)
    );
  }
}