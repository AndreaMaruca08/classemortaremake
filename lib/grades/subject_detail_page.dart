import 'package:classemortaremake/achievement/streak.dart';
import 'package:classemortaremake/core/extension/spacing_extension.dart';
import 'package:classemortaremake/core/extension/theme_extension.dart';
import 'package:classemortaremake/core/widgets/drawer.dart';
import 'package:classemortaremake/core/widgets/title.dart';
import 'package:classemortaremake/grades/grade.dart';
import 'package:classemortaremake/grades/grade_service.dart';
import 'package:classemortaremake/grades/subject.dart';
import 'package:classemortaremake/grades/widgets/grade_circle.dart';
import 'package:classemortaremake/grades/widgets/ratio_pie_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'Ipotetical.dart';
import 'hypotetical_preview.dart';

class SubjectDetailPage extends StatefulWidget {
  final Subject subject;
  final int period;
  final bool dotted;
  final int animationMs;

  const SubjectDetailPage({
    super.key,
    required this.subject,
    required this.period,
    this.dotted = false,
    required this.animationMs,
  });

  @override
  State<SubjectDetailPage> createState() => _SubjectDetailPageState();
}

class _SubjectDetailPageState extends State<SubjectDetailPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isDataReady = false;

  List<FlSpot> _trendSpots = [];
  List<FlSpot> _averageSpots = [];
  List<BarChartGroupData> _distributionGroups = [];
  double _maxFrequency = 0;

  @override
  void initState() {
    super.initState();
    _prepareData();
  }

  void _prepareData() async {
    List<Grade> periodGrades = widget.subject.grades
        .where((g) => widget.period == 3 || g.period == widget.period)
        .toList();
    periodGrades.sort((a, b) => a.date.compareTo(b.date));

    final validGrades = periodGrades.where((g) => !g.isCanceled).toList();
    final progressiveAverages =
    GradeService.calculateProgressiveAverages(validGrades);

    _trendSpots = List.generate(
      periodGrades.length,
          (i) => FlSpot(i.toDouble(), periodGrades[i].value),
    );

    _averageSpots = List.generate(
      progressiveAverages.length,
          (i) => FlSpot(i.toDouble(), progressiveAverages[i].value),
    );

    final Map<double, int> frequencies = {};
    for (var g in validGrades) {
      frequencies[g.value] = (frequencies[g.value] ?? 0) + 1;
    }

    double maxFreq = 0;
    _distributionGroups = [];
    for (double i = 0.0; i <= 10.0; i += 0.5) {
      final count = (frequencies[i] ?? 0).toDouble();
      if (count > maxFreq) maxFreq = count;
      _distributionGroups.add(
        BarChartGroupData(
          x: (i * 10).toInt(),
          barRods: [
            BarChartRodData(
              toY: count,
              color: GradeService.getGradeColor(i),
              width: 8,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ),
      );
    }

    if (mounted) {
      setState(() {
        _maxFrequency = maxFreq;
        _isDataReady = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Grade> periodGrades = widget.subject.grades
        .where((g) => widget.period == 3 || g.period == widget.period)
        .toList();
    periodGrades.sort((a, b) => b.date.compareTo(a.date));

    final double average = GradeService.getAverage(periodGrades);
    final streak = Streak().getStreak(periodGrades.reversed.toList());
    final ratio = Subject.ratio(periodGrades);
    final consistency = GradeService.calculateConsistency(average, periodGrades);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            PageTitle(
              text: widget.subject.subjectCode
                  + (widget.subject.subjectCode.length == 3 ?
                  (widget.period == 3 ? " anno" : " | ${widget.period} periodo"): ""),
              scaffoldKey: _scaffoldKey,
            ),
            16.height,
            _buildChartsHeader(),
            _buildChartsPager(average),
            _buildPagerIndicator(average),
            24.height,
            _RecentGradesRow(
              grades: periodGrades,
              animationMs: widget.animationMs,
            ),
            16.height,
            _SubjectStatsCard(
              average: average,
              streak: streak,
              ratio: ratio,
              teacherName: widget.subject.teacherName,
              consistency: consistency,
              grades: periodGrades,
            ),
            const SizedBox(height: 24),

            const Center(
              child: Text(
                "Medie ipotetiche",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
            const SizedBox(height: 12),

            Center(
              child: SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IpotetichePage(voti: periodGrades),
                      ),
                    );
                  },
                  child: const Text(
                    "Più voti",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Center(
              child: SizedBox(
                width: 320,
                child: HypotheticalPreview(
                  grades: periodGrades,
                  animationMs: widget.animationMs,
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsHeader() {
    String title = "Grafico andamento";
    if (_currentPage == 1) title = "Medie progressive";
    if (_currentPage == 2) title = "Distribuzione voti";

    return Text(
      title,
      style: context.textTheme.titleMedium,
    );
  }

  Widget _buildChartsPager(double average) {
    if (!_isDataReady) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      height: 300,
      child: PageView(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _currentPage = i),
        children: [
          _LineChart(
            spots: _trendSpots,
            color: GradeService.getGradeColor(average),
            showDots: widget.dotted || _trendSpots.length < 20,
            animationMs: widget.animationMs,
          ),
          _LineChart(
            spots: _averageSpots,
            color: GradeService.getGradeColor(average),
            showDots: widget.dotted || _averageSpots.length < 20,
            animationMs: widget.animationMs,
          ),
          _BarChart(
            groups: _distributionGroups,
            animationMs: widget.animationMs,
            maxFrequency: _maxFrequency,
          ),
        ],
      ),
    );
  }

  Widget _buildPagerIndicator(double average) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          width: 8.0,
          height: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? GradeService.getGradeColor(average)
                : Colors.grey.withOpacity(0.3),
          ),
        );
      }),
    );
  }
}

class _LineChart extends StatelessWidget {
  final List<FlSpot> spots;
  final Color color;
  final bool showDots;
  final int animationMs;

  const _LineChart({
    required this.spots,
    required this.color,
    required this.showDots,
    required this.animationMs,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 55, 24, 8),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: Duration(milliseconds: animationMs),
        curve: Curves.easeInOutCubic,
        builder: (context, value, child) {
          final animatedSpots =
          spots.map((spot) => FlSpot(spot.x, spot.y * value)).toList();

          return LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                getDrawingHorizontalLine: (v) =>
                    FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1),
                getDrawingVerticalLine: (v) =>
                    FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 2,
                    getTitlesWidget: (v, m) => Text(v.toInt().toString()),
                  ),
                ),
                bottomTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              minY: 0,
              maxY: 10,
              lineBarsData: [
                LineChartBarData(
                  spots: animatedSpots,
                  isCurved: true,
                  color: color,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: showDots),
                  belowBarData: BarAreaData(
                    show: true,
                    color: color.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<BarChartGroupData> groups;
  final int animationMs;
  final double maxFrequency;

  const _BarChart({
    required this.groups,
    required this.animationMs,
    required this.maxFrequency,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 8),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: Duration(milliseconds: animationMs),
        curve: Curves.easeInOutCubic,
        builder: (context, value, child) {
          final animatedGroups = groups.map((group) {
            return BarChartGroupData(
              x: group.x,
              barRods: group.barRods.map((rod) {
                return BarChartRodData(
                  toY: rod.toY * value,
                  color: rod.color,
                  width: rod.width,
                  borderRadius: rod.borderRadius,
                );
              }).toList(),
            );
          }).toList();

          return BarChart(
            BarChartData(
              maxY: maxFrequency + (maxFrequency * 0.2).clamp(1.0, 5.0),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (v, m) => Text(
                      v.toInt().toString(),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
                rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, m) {
                      if (v % 20 == 0) return Text((v / 10).toInt().toString());
                      return const SizedBox();
                    },
                  ),
                ),
              ),
              barGroups: animatedGroups,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final votoLabel = (group.x / 10.0).toStringAsFixed(1);
                    return BarTooltipItem(
                      'Voto $votoLabel\n',
                      const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: "Preso ${groups[groupIndex].barRods[0].toY.toInt()} volte",
                          style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                              fontSize: 12),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RecentGradesRow extends StatelessWidget {
  final List<Grade> grades;
  final int animationMs;

  const _RecentGradesRow({
    required this.grades,
    required this.animationMs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text("Ultimi voti", style: context.textTheme.titleMedium),
        ),
        8.height,
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: grades.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GradeCircle(
                grade: grades[i],
                size: 85,
                fontSize: 25,
                animationMs: animationMs,
                showDetailOnTap: true,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SubjectStatsCard extends StatelessWidget {
  final double average;
  final Streak streak;
  final List<double> ratio;
  final String teacherName;
  final double consistency;
  final List<Grade> grades;

  const _SubjectStatsCard({
    required this.average,
    required this.streak,
    required this.ratio,
    required this.teacherName,
    required this.consistency,
    required this.grades,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: context.containerDecoration,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Media"),
                    Text(
                      average.toStringAsFixed(2),
                      style: context.textTheme.titleLarge?.copyWith(
                        color: GradeService.getGradeColor(average),
                        fontSize: 32,
                      ),
                    ),
                    16.height,
                    const Text("Streak attuale"),
                    Row(
                      children: [
                        Icon(
                          streak.isActive
                              ? Icons.local_fire_department
                              : Icons.star_border,
                          color: streak.getStreakColor(),
                        ),
                        4.width,
                        Text(
                          streak.isGoated(grades)
                              ? "GOAT"
                              : streak.goodGrades.toString(),
                          style: context.textTheme.titleMedium?.copyWith(
                            color: streak.getStreakColor(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                RatioPieChart(ratio: ratio, size: 120),
              ],
            ),
            const Divider(height: 32),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 20),
                8.width,
                Expanded(
                  child: Text(
                    teacherName,
                    style: context.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Costanza", style: TextStyle(fontSize: 12)),
                    Text(
                      "${consistency.toStringAsFixed(1)}%",
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: GradeService.getGradeColor(average),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}