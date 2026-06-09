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
import '../localStorage/save.dart';
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
  final GradeService _gradeService = GradeService();
  final ExternalSiteService _externalSiteService = ExternalSiteService();
  final StudentService _studentService = StudentService();
  final Save _storage = Save();
  final HttpClient _client = HttpClient();

  late Future<OverviewData?> _overviewFuture;
  late Future<List<Grade>> _gradesFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
    _storage.getFavoriteAchievements(); // Initial load to populate notifier
  }

  void _loadData({bool forceRefresh = false}) {
    setState(() {
      _overviewFuture = _overviewService.fetchOverview(forceRefresh: forceRefresh);
      _gradesFuture = _gradeService.fetchGrades(forceRefresh: forceRefresh);
    });
  }

  Future<void> _handleRefresh() async {
    _loadData(forceRefresh: true);
    await _storage.getFavoriteAchievements();
    await Future.wait([_overviewFuture, _gradesFuture]);
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
              _buildHeader(),
              Padding(
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

                    // Achievements Summary (Overview Data)
                    FutureBuilder<OverviewData?>(
                      future: _overviewFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (snapshot.hasError || snapshot.data == null) {
                          return const SizedBox.shrink();
                        }
                        final data = snapshot.data!;
                        final reachedAchievements = data.achievements.where((a) => a.reached).toList();
                        final positiveReached = reachedAchievements.where((a) => a.isPositive).length;
                        final negativeReached = reachedAchievements.where((a) => !a.isPositive).length;
                        final totalPositive = data.achievements.where((a) => a.isPositive).length;
                        final totalNegative = data.achievements.where((a) => !a.isPositive).length;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                            
                            // Favorite Achievements (Reactive)
                            ValueListenableBuilder<List<String>>(
                              valueListenable: _storage.favoritesNotifier,
                              builder: (context, favoriteTitles, child) {
                                if (favoriteTitles.isEmpty) return const SizedBox.shrink();
                                return Column(
                                  children: [
                                    12.height,
                                    _FavoriteAchievementsRow(
                                      allAchievements: data.achievements,
                                      favoriteTitles: favoriteTitles,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),

                    24.height,

                    // Grades Data
                    FutureBuilder<List<Grade>>(
                      future: _gradesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (snapshot.hasError || !snapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Center(
                                child: Text("Errore durante il caricamento dei voti")),
                          );
                        }

                        final grades = snapshot.data!;
                        final averages = GradeService.getGeneralAverages(grades);
                        final streak = Streak().getStreak(grades.reversed.toList());

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                  allGrades: grades,
                                  animationMs: _client.settings.gradeAnimationMs,
                                ),
                                _AverageItem(
                                  title: "1° Periodo",
                                  grade: averages[1],
                                  allGrades: grades,
                                  animationMs: _client.settings.gradeAnimationMs,
                                ),
                                _AverageItem(
                                  title: "2° Periodo",
                                  grade: averages[2],
                                  allGrades: grades,
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
                                      builder: (context) => StreakDetailPage(grades: grades),
                                    ),
                                  ),
                                  child: _StreakWidget(streak: streak, grades: grades),
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
                                itemCount: grades.length,
                                separatorBuilder: (context, index) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final grade = grades[index];
                                  // Find previous grade for the same subject
                                  Grade? prev;
                                  for (int i = index + 1; i < grades.length; i++) {
                                    if (grades[i].subjectCode == grade.subjectCode) {
                                      prev = grades[i];
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
                          ],
                        );
                      },
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        PageTitle(text: "Home", scaffoldKey: _scaffoldKey),
        12.height,
      ],
    );
  }
}

class _FavoriteAchievementsRow extends StatelessWidget {
  final List<Achievement> allAchievements;
  final List<String> favoriteTitles;

  const _FavoriteAchievementsRow({
    required this.allAchievements,
    required this.favoriteTitles,
  });

  @override
  Widget build(BuildContext context) {
    // Filter to show only reached achievements and maintain order
    final List<Achievement> favorites = [];
    for (var title in favoriteTitles) {
      try {
        final found = allAchievements.firstWhere((a) => a.title == title);
        if (found.reached) {
          favorites.add(found);
        }
      } catch (_) {}
    }

    if (favorites.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "Trofei Preferiti",
            style: context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          children: favorites.map((a) {
            return Expanded(
              child: Container(
                height: 90,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: context.containerDecoration.copyWith(
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      a.display.icon,
                      color: a.display.color,
                      size: 26,
                    ),
                    6.height,
                    Text(
                      a.title,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
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
          color: goated ? Colors.yellow : streak.getStreakColor().withValues(alpha: 0.5),
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
