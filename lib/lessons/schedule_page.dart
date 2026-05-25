import 'package:flutter/material.dart';
import 'package:classemortaremake/core/extension/spacing_extension.dart';
import 'package:classemortaremake/core/extension/theme_extension.dart';
import 'package:classemortaremake/core/widgets/drawer.dart';
import 'package:classemortaremake/core/widgets/title.dart';
import 'day.dart';
import 'lesson_hour.dart';
import 'schedule_service.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScheduleService _service = ScheduleService();
  final PageController _pageController = PageController();
  
  late Future<List<List<Day>>> _scheduleFuture;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _scheduleFuture = _service.fetchTwoWeeksSchedule();
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
            child: FutureBuilder<List<List<Day>>>(
              future: _scheduleFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Errore: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data![0].isEmpty) {
                  return const Center(child: Text("Impossibile ricostruire l'orario"));
                }

                final weeks = snapshot.data!;
                
                return PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                    _buildWeekSection(weeks[0]),
                    _buildWeekSection(weeks[1]),
                  ],
                );
              },
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
          text: _currentPage == 0 ? "Orario Corrente" : "Orario Precedente", 
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

  Widget _buildWeekSection(List<Day> week) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(week.length, (index) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _DayColumn(day: week[index], dayIndex: index),
            ),
          );
        }),
      ),
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
        color: isActive ? context.colorScheme.primary : Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _DayColumn extends StatelessWidget {
  final Day day;
  final int dayIndex;

  const _DayColumn({required this.day, required this.dayIndex});

  static const List<String> _dayNames = [
    'Lun', 'Mar', 'Mer', 'Gio', 'Ven'
  ];

  List<Color> _getHourColors() {
    final List<List<Color>> dayPalettes = [
      [Colors.red[300]!, Colors.yellow[300]!, Colors.cyan[300]!, Colors.green[300]!, Colors.blue[300]!, Colors.orange[300]!, Colors.purple[300]!, Colors.teal[300]!],
      [Colors.blue[300]!, Colors.green[300]!, Colors.red[300]!, Colors.yellow[300]!, Colors.cyan[300]!, Colors.orange[300]!, Colors.purple[300]!, Colors.teal[300]!],
      [Colors.green[300]!, Colors.blue[300]!, Colors.yellow[300]!, Colors.cyan[300]!, Colors.red[300]!, Colors.orange[300]!, Colors.purple[300]!, Colors.teal[300]!],
      [Colors.yellow[300]!, Colors.cyan[300]!, Colors.green[300]!, Colors.blue[300]!, Colors.orange[300]!, Colors.red[300]!, Colors.purple[300]!, Colors.teal[300]!],
      [Colors.cyan[300]!, Colors.red[300]!, Colors.orange[300]!, Colors.yellow[300]!, Colors.blue[300]!, Colors.green[300]!, Colors.purple[300]!, Colors.teal[300]!],
    ];

    final palette = dayPalettes[dayIndex % 5];
    final List<Color> result = [];
    int colorIdx = 0;

    for (int i = 0; i < day.hours.length; i++) {
      result.add(palette[colorIdx % palette.length]);
      if (i < day.hours.length - 1 && day.hours[i].subject != day.hours[i+1].subject) {
        colorIdx++;
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getHourColors();

    return Container(
      decoration: context.containerDecoration.copyWith(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Text(
            _dayNames[dayIndex],
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70),
          ),
          4.height,
          const Divider(height: 1, thickness: 0.5),
          ...List.generate(day.hours.length, (i) {
            final hour = day.hours[i];
            final color = colors[i];
            
            return _HourItem(hour: hour, color: color);
          }),
        ],
      ),
    );
  }
}

class _HourItem extends StatelessWidget {
  final LessonHour hour;
  final Color color;

  const _HourItem({required this.hour, required this.color});

  String _shortenSubject(String name) {
    String sub = name.toUpperCase();
    if (sub.startsWith("TECN")) return "TPSI";
    if (sub.contains("ITALIANA")) return "ITAL";
    if (sub.contains("MATEMATICA")) return "MATE";
    if (sub.contains("INGLESE")) return "INGL";
    if (sub.contains("STORIA")) return "STOR";
    if (sub.contains("INFORMATICA")) return "INFO";
    if (sub.contains("RELIGIONE")) return "RELI";
    if (sub.contains("SCIENZE MOTORIE")) return "MOTR";
    
    if (sub.length > 4) return sub.substring(0, 4);
    return sub;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "${_shortenSubject(hour.subject)}${hour.teachers.length > 1 ? "★" : ""} | ${hour.hour}°",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
                shadows: const [Shadow(blurRadius: 2, offset: Offset(1, 1))],
              ),
            ),
          ),
          2.height,
          Expanded(
            child: Center(
              child: Text(
                hour.teachers.join("\n"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: hour.teachers.length > 1 ? 6 : 7.5,
                  color: color.withOpacity(0.9),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Divider(color: color.withOpacity(0.3), height: 1, thickness: 0.5),
        ],
      ),
    );
  }
}
