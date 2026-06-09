import 'package:classemortaremake/core/widgets/drawer.dart';
import 'package:classemortaremake/core/widgets/title.dart';
import 'package:flutter/material.dart';
import 'package:classemortaremake/core/extension/spacing_extension.dart';
import 'package:classemortaremake/core/extension/theme_extension.dart';
import 'package:classemortaremake/overview/overview_service.dart';
import 'package:classemortaremake/overview/models/overview_data.dart';
import 'package:intl/intl.dart';
import 'attendance.dart';

class AbsencesPage extends StatefulWidget {
  const AbsencesPage({super.key});

  @override
  State<AbsencesPage> createState() => _AbsencesPageState();
}

class _AbsencesPageState extends State<AbsencesPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final OverviewService _overviewService = OverviewService();
  final PageController _pageController = PageController();
  late Future<OverviewData?> _overviewFuture;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _overviewFuture = _overviewService.fetchOverview();
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
            child: FutureBuilder<OverviewData?>(
              future: _overviewFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || snapshot.data == null) {
                  return const Center(child: Text("Errore durante il caricamento"));
                }

                final data = snapshot.data!;
                final delays = [...data.delays, ...data.shortDelays];

                return PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                    _AttendanceList(list: data.absences, color: Colors.red),
                    _AttendanceList(list: delays, color: Colors.orange),
                    _AttendanceList(list: data.exits, color: Colors.blue),
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
    String title = "Assenze";
    if (_currentPage == 1) title = "Ritardi";
    if (_currentPage == 2) title = "Uscite";

    return Column(
      children: [
        PageTitle(text: title, scaffoldKey: _scaffoldKey),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ViewIndicator(isActive: _currentPage == 0),
            8.width,
            _ViewIndicator(isActive: _currentPage == 1),
            8.width,
            _ViewIndicator(isActive: _currentPage == 2),
          ],
        ),
        12.height,
      ],
    );
  }
}

class _AttendanceList extends StatelessWidget {
  final List<Attendance> list;
  final Color color;

  const _AttendanceList({required this.list, required this.color});

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.green.withValues(alpha: 0.5)),
            16.height,
            const Text("Ottimo! Nessun evento registrato."),
          ],
        ),
      );
    }

    final sortedList = List<Attendance>.from(list)..sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedList.length,
      itemBuilder: (context, index) {
        final item = sortedList[index];
        final date = DateTime.tryParse(item.date) ?? DateTime.now();
        final formattedDate = DateFormat('EEEE d MMMM yyyy', 'it_IT').format(date);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(Icons.event_note, color: color),
            ),
            title: Text(
              formattedDate,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.justification.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(item.justification),
                  ),
                4.height,
                Row(
                  children: [
                    Icon(
                      item.isJustified ? Icons.check_circle : Icons.warning_amber_rounded,
                      size: 16,
                      color: item.isJustified ? Colors.green : Colors.red,
                    ),
                    4.width,
                    Text(
                      item.isJustified ? "Giustificata" : "Da giustificare",
                      style: TextStyle(
                        fontSize: 12,
                        color: item.isJustified ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
