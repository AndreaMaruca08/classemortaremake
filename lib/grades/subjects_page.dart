import 'package:classemortaremake/core/api/http_client.dart';
import 'package:classemortaremake/core/extension/spacing_extension.dart';
import 'package:classemortaremake/core/widgets/drawer.dart';
import 'package:classemortaremake/core/widgets/title.dart';
import 'package:classemortaremake/grades/grade_service.dart';
import 'package:classemortaremake/grades/widgets/subject_card.dart';
import 'package:classemortaremake/overview/overview_service.dart';
import 'package:flutter/material.dart';

class SubjectsPage extends StatefulWidget {
  const SubjectsPage({super.key});

  @override
  State<SubjectsPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final OverviewService _overviewService = OverviewService();
  final HttpClient _client = HttpClient();

  late Future<List<dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  void _loadSubjects() {
    _dataFuture = _overviewService.fetchOverview().then((data) {
      if (data == null) return [];
      return GradeService.getSubjectsFromGrades(data.grades);
    });
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
            child: FutureBuilder<List<dynamic>>(
              future: _dataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final subjects = snapshot.data ?? [];

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      _dataFuture = _overviewService
                          .fetchOverview(forceRefresh: true)
                          .then((data) {
                        if (data == null) return [];
                        return GradeService.getSubjectsFromGrades(data.grades);
                      });
                    });
                    await _dataFuture;
                  },
                  child: CustomScrollView(
                    slivers: [
                      if (subjects.isEmpty)
                        const SliverFillRemaining(
                          child: Center(child: Text("Nessuna materia trovata")),
                        )
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return SubjectCard(
                                subject: subjects[index],
                                animationMs: _client.settings.gradeAnimationMs,
                              );
                            },
                            childCount: subjects.length,
                          ),
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  ),
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
        PageTitle(text: "Materie", scaffoldKey: _scaffoldKey),
        12.height,
      ],
    );
  }
}
