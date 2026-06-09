import 'package:classemortaremake/core/extension/spacing_extension.dart';
import 'package:classemortaremake/core/extension/theme_extension.dart';
import 'package:classemortaremake/core/widgets/drawer.dart';
import 'package:classemortaremake/core/widgets/title.dart';
import 'package:classemortaremake/overview/overview_service.dart';
import 'package:classemortaremake/overview/models/overview_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'info.dart';
import 'widgets/info_card.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final OverviewService _overviewService = OverviewService();
  final PageController _viewController = PageController();

  bool _showDone = true;
  bool _showPast = false;
  int _currentView = 0; // 0 for List, 1 for Calendar

  SharedPreferences? _prefs;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _selectedDay = _focusedDay;
  }

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() {});
  }

  Future<void> _handleRefresh() async {
    await _overviewService.fetchOverview(forceRefresh: true);
    if (mounted) setState(() {});
  }

  List<Info> _filterItems(List<Info> items) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    return items.where((i) {
      // 1. Filter done items if needed
      if (!_showDone && (_prefs?.getBool(i.storageKey) ?? false)) return false;

      // 2. Filter past/future
      try {
        if (i.date.length < 10) return true;
        final itemDate = DateTime.parse(i.date.substring(0, 10));
        if (!_showPast && itemDate.isBefore(todayDate)) return false;
      } catch (_) {
        return true;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: PageView(
                controller: _viewController,
                onPageChanged: (i) => setState(() => _currentView = i),
                children: [
                  _buildListView(),
                  _buildCalendarView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: PageTitle(
                  text: _currentView == 0 ? "Agenda" : "Calendario",
                  scaffoldKey: _scaffoldKey),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 44.0, right: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                        _showPast ? Icons.history : Icons.history_outlined,
                        size: 24,
                        color: _showPast
                            ? context.colorScheme.primary
                            : context.colorScheme.onSurface),
                    onPressed: () => setState(() => _showPast = !_showPast),
                    tooltip: _showPast ? "Nascondi passati" : "Mostra passati",
                  ),
                  const Text("Fatti", style: TextStyle(fontSize: 12)),
                  Transform.scale(
                    scale: 0.7,
                    child: Switch(
                      value: _showDone,
                      onChanged: (v) => setState(() => _showDone = v),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ViewIndicator(isActive: _currentView == 0),
            8.width,
            _ViewIndicator(isActive: _currentView == 1),
          ],
        ),
        12.height,
      ],
    );
  }

  Widget _buildListView() {
    return FutureBuilder<OverviewData?>(
      future: _overviewService.fetchOverview(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || snapshot.data == null) {
          return const Center(child: Text("Errore nel caricamento dei dati"));
        }

        final data = snapshot.data!;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection("Per domani", _filterItems(data.forTomorrow),
                  "Niente per domani"),
              _buildSection("Compiti", _filterItems(data.homeworks),
                  "Nessun compito trovato"),
              _buildSection("Cose da portare", _filterItems(data.agendaItems),
                  "Niente da portare"),
              _buildSection(
                  "Verifiche", _filterItems(data.tests), "Nessuna verifica"),
              _buildSection("Altro", _filterItems(data.otherAgenda),
                  "Nessun dato avanzato"),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 40, 16, 16),
                child: Text(
                  "Riepilogo scadenze",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              _buildSummary(data.eventCounts),
              const SizedBox(height: 120),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalendarView() {
    return FutureBuilder<OverviewData?>(
      future: _overviewService.fetchOverview(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data;
        if (data == null) return const Center(child: Text("Nessun dato"));

        // Flatten all events and apply filters
        final allEvents = _filterItems([
          ...data.homeworks,
          ...data.agendaItems,
          ...data.tests,
          ...data.otherAgenda
        ]);

        Map<DateTime, List<Info>> eventMap = {};
        for (var e in allEvents) {
          try {
            if (e.date.length < 10) continue;
            DateTime dt = DateTime.parse(e.date.substring(0, 10));
            DateTime day = DateTime(dt.year, dt.month, dt.day);
            eventMap.putIfAbsent(day, () => []).add(e);
          } catch (_) {}
        }

        final DateTime? selectedDayKey = _selectedDay != null
            ? DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)
            : null;
        final List<Info> selectedEvents =
            selectedDayKey != null ? (eventMap[selectedDayKey] ?? []) : [];

        return Column(
          children: [
            TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365 * 2)),
              lastDay: DateTime.now().add(const Duration(days: 365 * 2)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: CalendarFormat.month,
              locale: 'it_IT',
              startingDayOfWeek: StartingDayOfWeek.monday,
              eventLoader: (day) {
                final d = DateTime(day.year, day.month, day.day);
                return eventMap[d] ?? [];
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: (context.textTheme.titleMedium ?? const TextStyle()).copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.primary,
                ),
                leftChevronIcon:
                    Icon(Icons.chevron_left, color: context.colorScheme.primary),
                rightChevronIcon:
                    Icon(Icons.chevron_right, color: context.colorScheme.primary),
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
                markerDecoration: BoxDecoration(
                  color: context.colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                outsideDaysVisible: false,
                defaultTextStyle:
                    context.textTheme.bodyMedium ?? const TextStyle(),
                weekendTextStyle:
                    (context.textTheme.bodyMedium ?? const TextStyle())
                        .copyWith(color: Colors.red[300]),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
            ),
            const Divider(),
            Expanded(
              child: selectedEvents.isEmpty
                  ? Center(
                      child: Text("Nessun evento per questo giorno",
                          style: context.textTheme.bodySmall))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: selectedEvents.length,
                      itemBuilder: (context, index) {
                        final item = selectedEvents[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: InfoCard(
                            info: item,
                            onStatusChanged: () => setState(() {}),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSection(String title, List<Info> items, String emptyText) {
    Map<String, List<Info>> grouped = {};
    for (var item in items) {
      try {
        String date = item.date.substring(0, 10);
        grouped.putIfAbsent(date, () => []).add(item);
      } catch (_) {}
    }
    final sortedDates = grouped.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Text("$title (${items.length})", style: context.textTheme.titleMedium),
        ),
        if (sortedDates.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(emptyText,
                style: context.textTheme.bodySmall
                    ?.copyWith(fontStyle: FontStyle.italic)),
          )
        else
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: sortedDates.length,
              itemBuilder: (context, index) {
                final date = sortedDates[index];
                final dayItems = grouped[date]!;
                return _DateGroup(
                  date: date,
                  items: dayItems,
                  onRefresh: () => setState(() {}),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSummary(List<int> counts) {
    if (counts.isEmpty) return const SizedBox();
    final labels = [
      "Domani",
      "Dopodomani",
      "3 giorni",
      "4-7 giorni",
      "8-15 giorni",
      "+15 giorni"
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: List.generate(counts.length, (i) {
          final count = counts[i];
          final color = count == 0
              ? Colors.grey
              : (count < 3 ? Colors.green : (count < 5 ? Colors.orange : Colors.red));
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Text("Eventi per ", style: context.textTheme.bodySmall),
                Text(labels[i],
                    style: context.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(count.toString(),
                    style: context.textTheme.titleLarge?.copyWith(color: color)),
              ],
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
        color:
            isActive ? context.colorScheme.primary : Colors.grey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _DateGroup extends StatelessWidget {
  final String date;
  final List<Info> items;
  final VoidCallback onRefresh;

  const _DateGroup(
      {required this.date, required this.items, required this.onRefresh});

  String _formatDate(String dateStr) {
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('EEE d MMM', 'it_IT').format(dt);
    } catch (e) {
      return dateStr;
    }
  }

  String _getDistance(String dateStr) {
    DateTime today = DateTime.now();
    DateTime dt = DateTime.parse(dateStr);
    int diff =
        dt.difference(DateTime(today.year, today.month, today.day)).inDays;
    if (diff == 0) return "Oggi";
    if (diff == 1) return "Domani";
    if (diff == 2) return "Dopodomani";
    return "Tra $diff giorni";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8),
            child: Text(
              "${_formatDate(date)} - ${_getDistance(date)}",
              style: context.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            children: items
                .map((item) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: SizedBox(
                        height: 230,
                        child: InfoCard(info: item, onStatusChanged: onRefresh),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
