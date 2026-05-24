import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'auth/auth_wrapper.dart';

/// Entry point of the application.
void main() {
  runApp(const ClasseMortaPlus());
}

class ClasseMortaPlus extends StatelessWidget {
  const ClasseMortaPlus({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClasseMorta Plus',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      home: const AuthWrapper(isPreviousYear: false)
    );
  }
}