import 'package:classemortaremake/core/api/http_client.dart';
import 'package:classemortaremake/settings/settings_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';

import 'calendar/holidays_page.dart';
import 'didactic/didactic_page.dart';
import 'lessons/lessons_page.dart';
import 'lessons/schedule_page.dart';
import 'notes/notes_page.dart';
import 'pcto/pcto_page.dart';
import 'noticeboard/noticeboard_page.dart';
import 'absences/absences_page.dart';
import 'achievement/achievements_page.dart';
import 'core/theme/app_theme.dart';
import 'auth/auth_wrapper.dart';
import 'agenda/agenda_page.dart';
import 'grades/subjects_page.dart';
import 'home/home_page.dart';
import 'subjects/subjects_teacher_page.dart';
import 'core/api/page_transition.dart';

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('it_IT', null);
  
  final client = HttpClient();
  await client.settings.loadSettings();
  themeNotifier.value = client.settings.themeMode;
  
  runApp(const ClasseMortaPlus());
}

class ClasseMortaPlus extends StatelessWidget {
  const ClasseMortaPlus({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentThemeMode, child) {
        return MaterialApp(
          title: 'ClasseMorta Plus',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: currentThemeMode,
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
          onGenerateRoute: (settings) {
            Widget page;
            switch (settings.name) {
              case '/':
                page = const AuthWrapper(isPreviousYear: false);
                break;
              case '/home':
                page = const HomePage(studentCode: '');
                break;
              case '/subjects':
                page = const SubjectsPage();
                break;
              case '/agenda':
                page = const AgendaPage();
                break;
              case '/absences':
                page = const AbsencesPage();
                break;
              case '/noticeboard':
                page = const NoticeboardPage();
                break;
              case '/notes':
                page = const NotesPage();
                break;
              case '/report_cards':
                page = _placeholder("Pagelle");
                break;
              case '/didactic':
                page = const DidacticPage();
                break;
              case '/lessons':
                page = const LessonsPage();
                break;
              case '/schedule':
                page = const SchedulePage();
                break;
              case '/teachers':
                page = const SubjectTeacherPage();
                break;
              case '/curriculum':
                page = const PctoPage();
                break;
              case '/justifications':
                page = _placeholder("Giustifiche");
                break;
              case '/holidays':
                page = const HolidaysPage();
                break;
              case '/achievements':
                page = const AchievementsPage();
                break;
              case '/settings':
                page = const SettingsPage();
                break;
              default:
                return null;
            }
            return CustomPageRoute(child: page);
          },
        );
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
