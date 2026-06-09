import 'package:flutter/material.dart';
import 'package:classemortaremake/core/extension/spacing_extension.dart';
import 'package:classemortaremake/core/extension/theme_extension.dart';
import 'package:classemortaremake/core/widgets/drawer.dart';
import 'package:classemortaremake/core/widgets/title.dart';
import 'didactic_item.dart';
import 'didactic_service.dart';
import 'widgets/didactic_card.dart';

class DidacticPage extends StatefulWidget {
  const DidacticPage({super.key});

  @override
  State<DidacticPage> createState() => _DidacticPageState();
}

class _DidacticPageState extends State<DidacticPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DidacticService _service = DidacticService();
  final PageController _pageController = PageController();
  
  late Future<List<DidacticItem>> _didacticFuture;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _didacticFuture = _service.fetchDidactics();
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
            child: FutureBuilder<List<DidacticItem>>(
              future: _didacticFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Errore: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Nessun file didattico trovato"));
                }

                final items = snapshot.data!;

                return PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                    _buildTimelineView(items),
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
          text: _currentPage == 0 ? "Didattica (Recenti)" : "Didattica (Docenti)",
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

  Widget _buildTimelineView(List<DidacticItem> items) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => 16.height,
      itemBuilder: (context, index) {
        return IntrinsicHeight(
          child: DidacticCard(item: items[index]),
        );
      },
    );
  }

  Widget _buildByTeacherView(List<DidacticItem> items) {
    // Group by teacher
    final Map<String, List<DidacticItem>> grouped = {};
    for (var item in items) {
      grouped.putIfAbsent(item.teacher, () => []).add(item);
    }
    
    final teachers = grouped.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.only(top: 16),
      itemCount: teachers.length,
      itemBuilder: (context, index) {
        final teacher = teachers[index];
        final teacherItems = grouped[teacher]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Text(
                teacher,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: teacherItems.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: DidacticCard(item: teacherItems[i], horizontal: true),
                  );
                },
              ),
            ),
            24.height,
          ],
        );
      },
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
