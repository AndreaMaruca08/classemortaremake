import 'package:flutter/material.dart';
import '../achievement/achievement.dart';
import '../achievement/streak.dart';
import '../achievement/streak_detail_page.dart';
import '../core/api/http_client.dart';
import '../core/services/external_site_service.dart';
import '../core/widgets/drawer.dart';
import '../core/widgets/title.dart';
import '../grades/grade.dart';
import '../grades/grade_detail.dart';
import '../grades/grade_service.dart';
import '../grades/subject.dart';
import '../grades/subject_detail_page.dart';
import '../grades/widgets/grade_circle.dart';
import '../overview/overview_service.dart';
import '../overview/models/overview_data.dart';
import '../student/student_detail.dart';
import '../student/student_service.dart';
import 'package:classemortaremake/core/extension/spacing_extension.dart';
import 'package:classemortaremake/core/extension/theme_extension.dart';

class HomePage extends StatefulWidget {
  final String studentCode;

  const HomePage({super.key, required this.studentCode});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final OverviewService _overviewService = OverviewService();
  final ExternalSiteService _externalSiteService = ExternalSiteService();
  final StudentService _studentService = StudentService();
  final HttpClient _client = HttpClient();

  late Future<OverviewData?> _overviewFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData({bool forceRefresh = false}) {
    setState(() {
      _overviewFuture = _overviewService.fetchOverview(forceRefresh: forceRefresh);
    });
  }

  Future<void> _handleRefresh() async {
    _loadData(forceRefresh: true);
    await _overviewFuture;
  }

  Future<void> _openRegistryWeb() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _externalSiteService.launchRegistryWeb();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore apertura: $e')),
        );
      }
    }
  }

  Future<void> _goToStudentDetail() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final card = await _studentService.fetchStudentCard();

    if (mounted) {
      Navigator.pop(context);
      if (card != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StudentDetail(card: card)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Impossibile caricare i dettagli studente")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageTitle(text: "Home", scaffoldKey: _scaffoldKey),
              FutureBuilder<OverviewData?>(
                future: _overviewFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError || snapshot.data == null) {
                    return const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                          child: Text("Errore durante il caricamento dei dati")),
                    );
                  }

                  final data = snapshot.data!;
                  final averages = GradeService.getGeneralAverages(data.grades);
                  final streak = Streak().getStreak(data.grades.reversed.toList());
                  final reachedAchievements = data.achievements.where((a) => a.reached).toList();
                  final positiveReached = reachedAchievements.where((a) => a.isPositive).length;
                  final negativeReached = reachedAchievements.where((a) => !a.isPositive).length;
                  final totalPositive = data.achievements.where((a) => a.isPositive).length;
                  final totalNegative = data.achievements.where((a) => !a.isPositive).length;

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_client.isPreviousYear)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              "ANNO PRECEDENTE",
                              style: TextStyle(
                                  color: Colors.red[800],
                                  fontWeight: FontWeight.bold),
                            ),
                          ),

                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Buongiorno ${_client.firstName ?? ''} ${_client.lastName ?? ''}",
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              onPressed: _goToStudentDetail,
                              icon: const Icon(Icons.info_outline),
                              tooltip: 'Dettagli studente',
                            ),
                          ],
                        ),

                        8.height,

                        // Achievements Summary
                        InkWell(
                          onTap: () => Navigator.pushNamed(context, '/achievements'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: context.containerDecoration,
                            child: Row(
                              children: [
                                const Icon(Icons.emoji_events, color: Colors.orange),
                                12.width,
                                const Text(
                                  "Trofei",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                Text(
                                  "Pos: $positiveReached/$totalPositive",
                                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                ),
                                8.width,
                                Text(
                                  "Neg: $negativeReached/$totalNegative",
                                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),

                        24.height,

                        const Text(
                          "Medie Generali",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        16.height,

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _AverageItem(
                              title: "Totale",
                              grade: averages[0],
                              allGrades: data.grades,
                              animationMs: _client.settings.gradeAnimationMs,
                            ),
                            _AverageItem(
                              title: "1° Periodo",
                              grade: averages[1],
                              allGrades: data.grades,
                              animationMs: _client.settings.gradeAnimationMs,
                            ),
                            _AverageItem(
                              title: "2° Periodo",
                              grade: averages[2],
                              allGrades: data.grades,
                              animationMs: _client.settings.gradeAnimationMs,
                            ),
                          ],
                        ),

                        12.height,

                        // Streak Row
                        Row(
                          children: [
                            const Text(
                              "Ultimi Voti",
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StreakDetailPage(grades: data.grades),
                                ),
                              ),
                              child: _StreakWidget(streak: streak, grades: data.grades),
                            ),
                          ],
                        ),
                        16.height,

                        // Grades List
                        Container(
                          height: 270,
                          decoration: context.containerDecoration,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            itemCount: data.grades.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final grade = data.grades[index];
                              // Find previous grade for the same subject
                              Grade? prev;
                              for (int i = index + 1; i < data.grades.length; i++) {
                                if (data.grades[i].subjectCode == grade.subjectCode) {
                                  prev = data.grades[i];
                                  break;
                                }
                              }

                              return _GradeListTile(
                                grade: grade,
                                previousGrade: prev,
                                animationMs: _client.settings.gradeAnimationMs,
                              );
                            },
                          ),
                        ),

                        32.height,

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: _openRegistryWeb,
                            child: const Text("Apri Registro Web"),
                          ),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AverageItem extends StatelessWidget {
  final String title;
  final Grade grade;
  final List<Grade> allGrades;
  final int animationMs;

  const _AverageItem({
    required this.title,
    required this.grade,
    required this.allGrades,
    required this.animationMs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GradeCircle(
          grade: grade,
          size: 90,
          fontSize: 18,
          animationMs: animationMs,
          onTap: () => _navigateToDetail(context),
        ),
        8.height,
        Text(
          title,
          style: context.textTheme.bodySmall,
        ),
      ],
    );
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubjectDetailPage(
          subject: Subject(
            subjectCode: title,
            subjectFullName: "Riepilogo $title",
            teacherName: "Sistema",
            grades: allGrades,
          ),
          period: grade.period,
          animationMs: animationMs,
        ),
      ),
    );
  }
}

class _StreakWidget extends StatelessWidget {
  final Streak streak;
  final List<Grade> grades;

  const _StreakWidget({required this.streak, required this.grades});

  @override
  Widget build(BuildContext context) {
    final bool goated = streak.isGoated(grades);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: goated ? Colors.yellow : streak.getStreakColor().withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "   Streak: ",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Icon(
            goated ? Icons.star : Icons.local_fire_department,
            color: goated ? Colors.yellow : streak.getStreakColor(),
            size: 20,
          ),
          Text(
            " ${goated ? "GOAT" : streak.goodGrades}     ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: goated ? Colors.yellow : streak.getStreakColor(),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradeListTile extends StatelessWidget {
  final Grade grade;
  final Grade? previousGrade;
  final int animationMs;

  const _GradeListTile({
    required this.grade,
    this.previousGrade,
    required this.animationMs,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GradeDetail(
              grade: grade,
              previousGrade: previousGrade,
              animationMs: animationMs,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            GradeCircle(
              grade: grade,
              previousGrade: previousGrade,
              size: 65,
              fontSize: 18,
              animationMs: animationMs,
              showDetailOnTap: false,
            ),
            16.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    grade.subjectFullName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  4.height,
                  Text(
                    "${grade.date} • ${grade.type}",
                    style: context.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 24, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
