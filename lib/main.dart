import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'auth/auth_wrapper.dart';
import 'agenda/agenda_page.dart';
import 'grades/subjects_page.dart';
import 'home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('it_IT', null);
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
      debugShowCheckedModeBanner: false,
      locale: const Locale('it', 'IT'),
      supportedLocales: const [
        Locale('it', 'IT'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AuthWrapper(isPreviousYear: false),
      routes: {
        '/home': (context) => const HomePage(studentCode: ''),
        '/subjects': (context) => const SubjectsPage(),
        '/agenda': (context) => const AgendaPage(),
        '/noticeboard': (context) => _placeholder("Notizie"),
        '/notes': (context) => _placeholder("Note"),
        '/report_cards': (context) => _placeholder("Pagelle"),
        '/didactic': (context) => _placeholder("Didattica"),
        '/schedule': (context) => _placeholder("Orari"),
        '/curriculum': (context) => _placeholder("Curriculum"),
        '/justifications': (context) => _placeholder("Giustifiche"),
        '/holidays': (context) => _placeholder("Vacanze"),
        '/achievements': (context) => _placeholder("Trofei"),
        '/settings': (context) => _placeholder("Impostazioni"),
      },
    );
  }

  Widget _placeholder(String title) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(child: Text("Coming Soon")),
    );
  }
}
