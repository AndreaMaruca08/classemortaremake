import 'package:flutter/material.dart';
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

                        32.height,

                        ElevatedButton(
                          onPressed: _openRegistryWeb,
                          child: const Text("Apri Registro Web"),
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
        IconButton(
          onPressed: () => _navigateToDetail(context),
          icon: const Icon(Icons.auto_graph_sharp, size: 20),
          tooltip: 'Dettagli $title',
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
