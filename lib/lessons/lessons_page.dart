import 'package:flutter/material.dart';
import 'package:classemortaremake/core/extension/spacing_extension.dart';
import 'package:classemortaremake/core/extension/theme_extension.dart';
import 'package:classemortaremake/core/widgets/drawer.dart';
import 'package:classemortaremake/core/widgets/title.dart';
import 'package:table_calendar/table_calendar.dart';
import 'lesson_hour.dart';
import 'lesson_service.dart';
import 'widgets/lesson_card.dart';

class LessonsPage extends StatefulWidget {
  const LessonsPage({super.key});

  @override
  State<LessonsPage> createState() => _LessonsPageState();
}

class _LessonsPageState extends State<LessonsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final LessonService _service = LessonService();
  final PageController _pageController = PageController();
  
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int _currentPage = 0;

  late Future<List<LessonHour>> _todayLessonsFuture;
  Future<List<LessonHour>>? _selectedDateLessonsFuture;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _todayLessonsFuture = _service.getTodayLessons();
    _selectedDateLessonsFuture = _service.getLessonsForDate(_selectedDay!);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: [
                _buildTodayPage(),
                _buildCalendarPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        PageTitle(
          text: _currentPage == 0 ? "Lezioni Oggi" : "Registro Lezioni",
          scaffoldKey: _scaffoldKey,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ViewIndicator(isActive: _currentPage == 0),
            8.width,
            _ViewIndicator(isActive: _currentPage == 1),
          ],
        ),
        12.height,
      ],
    );
  }

  Widget _buildTodayPage() {
    return FutureBuilder<List<LessonHour>>(
      future: _todayLessonsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Errore: ${snapshot.error}"));
        }
        final lessons = snapshot.data ?? [];
        if (lessons.isEmpty) {
          return const Center(child: Text("Nessuna lezione registrata per oggi"));
        }

        lessons.sort((a, b) => a.hour.compareTo(b.hour));

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(5, 10, 5, 60),
          itemCount: lessons.length,
          separatorBuilder: (context, index) => 12.height,
          itemBuilder: (context, index) => LessonCard(lesson: lessons[index]),
        );
      },
    );
  }

  Widget _buildCalendarPage() {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: CalendarFormat.month,
          locale: 'it_IT',
          startingDayOfWeek: StartingDayOfWeek.monday,
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: (context.textTheme.titleMedium ?? const TextStyle()).copyWith(
              fontWeight: FontWeight.bold,
              color: context.colorScheme.primary,
            ),
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: context.colorScheme.primary.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: context.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
              _selectedDateLessonsFuture = _service.getLessonsForDate(selectedDay);
            });
          },
        ),
        const Divider(),
        Expanded(
          child: FutureBuilder<List<LessonHour>>(
            future: _selectedDateLessonsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final lessons = snapshot.data ?? [];
              if (lessons.isEmpty) {
                return Center(
                  child: Text(
                    "Nessuna lezione per questo giorno",
                    style: context.textTheme.bodySmall,
                  ),
                );
              }

              lessons.sort((a, b) => a.hour.compareTo(b.hour));

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: lessons.length,
                separatorBuilder: (context, index) => 12.height,
                itemBuilder: (context, index) => LessonCard(lesson: lessons[index]),
              );
            },
          ),
        ),
        52.height
      ],
    );
  }
}

class _ViewIndicator extends StatelessWidget {
  final bool isActive;
  const _ViewIndicator({required this.isActive});
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 4,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? context.colorScheme.primary : Colors.grey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
