import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:classemortaremake/core/extension/spacing_extension.dart';
import 'package:classemortaremake/core/extension/theme_extension.dart';
import 'package:classemortaremake/core/widgets/drawer.dart';
import 'package:classemortaremake/core/widgets/title.dart';
import 'holiday_period.dart';
import 'holiday_service.dart';

class HolidaysPage extends StatefulWidget {
  const HolidaysPage({super.key});

  @override
  State<HolidaysPage> createState() => _HolidaysPageState();
}

class _HolidaysPageState extends State<HolidaysPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final HolidayService _service = HolidayService();
  late Future<List<HolidayPeriod>> _holidaysFuture;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _holidaysFuture = _service.fetchHolidays();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
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
            child: FutureBuilder<List<HolidayPeriod>>(
              future: _holidaysFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Errore: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Nessun dato sulle vacanze trovato"));
                }

                final periods = snapshot.data!;
                final DateTime christmas = DateTime(DateTime.now().year, 12, 25);
                final DateTime schoolEnd = periods.last.start;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("Eventi Speciali"),
                      12.height,
                      _SpecialEventCard(title: "Natale", targetDate: christmas, icon: Icons.celebration),
                      12.height,
                      _SpecialEventCard(title: "Fine della scuola", targetDate: schoolEnd, icon: Icons.school),
                      24.height,
                      _buildSectionTitle("Periodi di vacanza"),
                      8.height,
                      Text(
                        "(Esclusi i weekend standard)",
                        style: context.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                      ),
                      16.height,
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: periods.length,
                        separatorBuilder: (context, index) => 12.height,
                        itemBuilder: (context, index) {
                          return _HolidayPeriodCard(period: periods[index]);
                        },
                      ),
                      80.height,
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
        PageTitle(text: "Vacanze", scaffoldKey: _scaffoldKey),
        12.height,
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    );
  }
}

class _SpecialEventCard extends StatelessWidget {
  final String title;
  final DateTime targetDate;
  final IconData icon;

  const _SpecialEventCard({
    required this.title,
    required this.targetDate,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final difference = targetDate.difference(now);
    final bool isPassed = difference.isNegative;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: context.containerDecoration.copyWith(
        gradient: LinearGradient(
          colors: [
            context.colorScheme.surface,
            context.colorScheme.primary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: context.colorScheme.primary),
              12.width,
              Text(
                title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          20.height,
          if (isPassed)
            const Text(
              "Evento già passato :(",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCountdownItem(difference.inDays, "Giorni"),
                _buildCountdownItem(difference.inHours % 24, "Ore"),
                _buildCountdownItem(difference.inMinutes % 60, "Min"),
                _buildCountdownItem(difference.inSeconds % 60, "Sec"),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCountdownItem(int value, String label) {
    return Column(
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

class _HolidayPeriodCard extends StatelessWidget {
  final HolidayPeriod period;

  const _HolidayPeriodCard({required this.period});

  bool _isSummer() {
    // Summer holidays in Italy are between June (6) and September (9) of the same year
    return period.start.month >= 6 && 
           period.end.month <= 9 && 
           period.start.year == period.end.year;
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEE d MMM yyyy', 'it_IT').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = period.end.difference(period.start).inDays + 1;
    final remaining = period.start.difference(now).inDays;
    final isSummer = _isSummer();
    final Color accentColor = isSummer ? Colors.blue : Colors.green;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: context.containerDecoration.copyWith(
        border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isSummer ? "Vacanza Estiva" : "Vacanza",
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$days giorni",
                  style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          12.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_formatDate(period.start), style: const TextStyle(fontWeight: FontWeight.w600)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.arrow_forward, size: 16, color: Colors.grey.withValues(alpha: 0.5)),
              ),
              Text(_formatDate(period.end), style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          12.height,
          Text(
            remaining < 0 ? "Già passata" : "Mancano $remaining giorni",
            style: context.textTheme.bodyMedium?.copyWith(
              color: remaining < 0 ? Colors.grey : context.colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
