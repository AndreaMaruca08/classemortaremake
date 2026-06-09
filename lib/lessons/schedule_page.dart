import 'package:flutter/material.dart';
import 'package:classemortaremake/core/extension/spacing_extension.dart';
import 'package:classemortaremake/core/extension/theme_extension.dart';
import 'package:classemortaremake/core/widgets/drawer.dart';
import 'package:classemortaremake/core/widgets/title.dart';
import 'package:classemortaremake/core/services/pdf_service.dart';
import 'day.dart';
import 'lesson_hour.dart';
import 'schedule_service.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return _SchedulePageContent();
  }
}

class _SchedulePageContent extends StatefulWidget {
  @override
  State<_SchedulePageContent> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<_SchedulePageContent> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScheduleService _service = ScheduleService();
  final PageController _pageController = PageController();
  
  late Future<List<List<Day>>> _scheduleFuture;
  List<List<Day>>? _weeks;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _scheduleFuture = _service.fetchTwoWeeksSchedule().then((value) {
      setState(() => _weeks = value);
      return value;
    });
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            FutureBuilder<List<List<Day>>>(
              future: _scheduleFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Errore: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data![0].isEmpty) {
                  return const Center(child: Text("Impossibile ricostruire l'orario"));
                }

                final weeks = snapshot.data!;
                
                return Column(
                  children: [
                    SizedBox(
                      height: 720, // Altezza fissa per l'orario settimanale
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (i) => setState(() => _currentPage = i),
                        children: [
                          _buildWeekSection(weeks[0]),
                          _buildWeekSection(weeks[1]),
                        ],
                      ),
                    ),
                    _buildSummarySection(weeks[_currentPage]),
                    const SizedBox(height: 50),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(List<Day> week) {
    final Map<String, List<int>> subjectCounts = {};
    for (int i = 0; i < week.length; i++) {
      for (var hour in week[i].hours) {
        final subject = hour.subject;
        subjectCounts.putIfAbsent(subject, () => List.filled(5, 0));
        if (i < 5) subjectCounts[subject]![i]++;
      }
    }

    final subjects = subjectCounts.keys.toList()..sort();

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 16, 10, 10),
      padding: const EdgeInsets.all(12),
      decoration: context.containerDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, size: 16, color: context.colorScheme.secondary),
              8.width,
              const Text(
                "Riepilogo Ore Settimanali",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          8.height,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 18,
              horizontalMargin: 4,
              headingRowHeight: 32,
              dataRowHeight: 32,
              columns: const [
                DataColumn(label: SizedBox(width: 80, child: Text("Materia", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)))),
                DataColumn(label: Text("Tot", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                DataColumn(label: Text("L", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                DataColumn(label: Text("M", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                DataColumn(label: Text("M", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                DataColumn(label: Text("G", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                DataColumn(label: Text("V", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
              ],
              rows: subjects.map((sub) {
                final counts = subjectCounts[sub]!;
                final total = counts.reduce((a, b) => a + b);
                return DataRow(cells: [
                  DataCell(SizedBox(width: 80, child: Text(sub, style: const TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis))),
                  DataCell(Text(total.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: context.colorScheme.secondary))),
                  ...counts.map((c) => DataCell(
                    Center(child: Text(c == 0 ? "-" : c.toString(), style: const TextStyle(fontSize: 10))),
                  )),
                ]);
              }).toList(),
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
          actions: [
            if (_weeks != null)
              IconButton(
                icon: const Icon(Icons.picture_as_pdf_outlined),
                onPressed: () {
                  PdfService.generateSchedulePdf(
                    week: _weeks![_currentPage],
                    title: _currentPage == 0 ? "Orario Corrente" : "Orario Precedente",
                  );
                },
              ),
          ],
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
        color: isActive ? context.colorScheme.primary : context.colorScheme.onSurface.withValues(alpha: 0.2),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: context.containerDecoration,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Text(
            _dayNames[dayIndex],
            style: TextStyle(
              fontSize: 11, 
              fontWeight: FontWeight.bold, 
              color: context.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          4.height,
          Divider(height: 1, thickness: 0.5, color: context.colorScheme.onSurface.withValues(alpha: 0.1)),
          ...day.hours.map((hour) => _HourItem(hour: hour)),
        ],
      ),
    );
  }
}

class _HourItem extends StatelessWidget {
  final LessonHour hour;

  const _HourItem({required this.hour});

  static const List<Color> _palette = [
    Colors.redAccent, Colors.blueAccent, Colors.greenAccent, Colors.orangeAccent,
    Colors.purpleAccent, Colors.tealAccent, Colors.cyanAccent, Colors.amberAccent,
    Colors.indigoAccent, Colors.pinkAccent, Colors.deepOrangeAccent, Colors.lightGreenAccent,
    Colors.deepPurpleAccent, Colors.limeAccent, Colors.lightBlueAccent, Color(0xFFE57373),
    Color(0xFF81C784), Color(0xFF64B5F6), Color(0xFFFFB74D), Color(0xFFBA68C8),
    Color(0xFF4DB6AC), Color(0xFF9575CD), Color(0xFFAED581), Color(0xFFFF8A65),
    Color(0xFF4FC3F7), Color(0xFFD4E157), Color(0xFFFF7043), Color(0xFF26A69A),
    Color(0xFF5C6BC0), Color(0xFFEC407A), Colors.red, Colors.blue, Colors.green,
    Colors.orange, Colors.purple, Colors.teal, Colors.cyan, Colors.indigo,
    Colors.pink, Colors.brown,
  ];

  Color _getSubjectColor(String subject) {
    if (subject.isEmpty) return Colors.grey;
    String name = subject.trim().toUpperCase();
    int hash = 5381;
    for (int i = 0; i < name.length; i++) {
      hash = ((hash << 5) + hash) + name.codeUnitAt(i);
    }
    return _palette[hash.abs() % _palette.length].withValues(alpha: 0.8);
  }

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
    final color = _getSubjectColor(hour.subject);

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
                shadows: [
                  Shadow(
                    blurRadius: 2, 
                    offset: const Offset(1, 1), 
                    color: Colors.black.withValues(alpha: 0.3),
                  )
                ],
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
                  color: color.withValues(alpha: 0.9),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Divider(color: color.withValues(alpha: 0.2), height: 1, thickness: 0.5),
        ],
      ),
    );
  }
}
