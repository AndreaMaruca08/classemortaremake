import 'package:flutter/material.dart';
import 'package:classemortaremake/core/extension/spacing_extension.dart';
import 'package:classemortaremake/core/extension/theme_extension.dart';
import 'package:classemortaremake/core/widgets/drawer.dart';
import 'package:classemortaremake/core/widgets/title.dart';
import 'subject_teacher.dart';
import 'subject_service.dart';
import 'widgets/subject_teacher_card.dart';

class SubjectTeacherPage extends StatefulWidget {
  const SubjectTeacherPage({super.key});

  @override
  State<SubjectTeacherPage> createState() => _SubjectTeacherPageState();
}

class _SubjectTeacherPageState extends State<SubjectTeacherPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final SubjectTeacherService _service = SubjectTeacherService();
  final PageController _pageController = PageController();
  
  late Future<List<SubjectTeacher>> _subjectsFuture;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _subjectsFuture = _service.fetchSubjects();
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
            child: FutureBuilder<List<SubjectTeacher>>(
              future: _subjectsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Errore: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Nessuna materia trovata"));
                }

                final items = snapshot.data!;

                return PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                    _buildListView(items),
                    _buildByTeacherView(items),
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
          text: _currentPage == 0 ? "Materie e Docenti" : "Docenti e Materie",
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

  Widget _buildListView(List<SubjectTeacher> items) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => 16.height,
      itemBuilder: (context, index) {
        return SubjectTeacherCard(item: items[index]);
      },
    );
  }

  Widget _buildByTeacherView(List<SubjectTeacher> items) {
    final Map<String, List<String>> teacherSubjects = {};
    for (var item in items) {
      for (var teacher in item.teachers) {
        teacherSubjects.putIfAbsent(teacher.name, () => []).add(item.description);
      }
    }
    
    final teachers = teacherSubjects.keys.toList()..sort();

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: teachers.length,
      separatorBuilder: (context, index) => 16.height,
      itemBuilder: (context, index) {
        final teacher = teachers[index];
        final subjects = teacherSubjects[teacher]!;
        final color = _getTeacherColor(teacher);

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: context.containerDecoration.copyWith(
            border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.2),
                    radius: 14,
                    child: Text(
                      teacher.isNotEmpty ? teacher[0].toUpperCase() : "?",
                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  8.width,
                  Expanded(
                    child: Text(
                      teacher,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              12.height,
              ...subjects.map((sub) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  children: [
                    Icon(Icons.book, size: 14, color: Colors.grey.withValues(alpha: 0.7)),
                    8.width,
                    Expanded(
                      child: Text(
                        sub,
                        style: context.textTheme.bodyMedium?.copyWith(fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        );
      },
    );
  }

  Color _getTeacherColor(String name) {
    if (name.isEmpty) return Colors.grey;
    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash = name.codeUnitAt(i) + ((hash << 5) - hash);
    }
    final List<Color> colors = [
      Colors.redAccent,
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.tealAccent,
      Colors.cyanAccent,
      Colors.amberAccent,
      Colors.indigoAccent,
      Colors.pinkAccent,
      Colors.deepOrangeAccent,
      Colors.lightGreenAccent,
      Colors.deepPurpleAccent,
      Colors.limeAccent,
      Colors.lightBlueAccent,
      const Color(0xFFE57373),
      const Color(0xFF81C784),
      const Color(0xFF64B5F6),
      const Color(0xFFFFB74D),
      const Color(0xFFBA68C8),
      const Color(0xFF4DB6AC),
      const Color(0xFF9575CD),
      const Color(0xFFAED581),
      const Color(0xFFFF8A65),
      const Color(0xFF4FC3F7),
      const Color(0xFFD4E157),
      const Color(0xFFFF7043),
      const Color(0xFF26A69A),
      const Color(0xFF5C6BC0),
      const Color(0xFFEC407A),
    ];
    return colors[hash.abs() % colors.length];
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
