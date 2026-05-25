import 'package:flutter/material.dart';
import 'package:classemortaremake/core/extension/spacing_extension.dart';
import 'package:classemortaremake/core/extension/theme_extension.dart';
import 'package:classemortaremake/grades/grade.dart';
import 'streak.dart';

class StreakDetailPage extends StatelessWidget {
  final List<Grade> grades;
  const StreakDetailPage({
    required this.grades,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final List<Streak> allStreaks = Streak.getAllStreaks(grades);
    final Streak currentStreak = Streak().getStreak(grades.reversed.toList());

    final int longestStreak = allStreaks.fold(0, (max, s) => s.goodGrades > max ? s.goodGrades : max);
    final int firstStreak = allStreaks.isNotEmpty ? allStreaks.first.goodGrades : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettaglio Streak'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Riepilogo',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              16.height,
              _buildStatsRow(currentStreak, longestStreak, firstStreak),
              24.height,
              const Divider(),
              16.height,

              const Text(
                'Tutte le Streak',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              10.height,

              if (allStreaks.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(
                    child: Text(
                      'Nessuna streak di voti positivi trovata.',
                      style: context.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: allStreaks.length,
                  itemBuilder: (BuildContext context, int index) {
                    final streak = allStreaks[index];
                    final int streakNumber = allStreaks.length - index;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: _StreakItemWidget(streak: streak, number: streakNumber),
                    );
                  },
                ),
              20.height,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(Streak currentStreak, int longestStreak, int firstStreak) {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatWidget(label: 'Attuale', value: currentStreak.goodGrades.toString(), color: currentStreak.getStreakColor()),
          const VerticalDivider(thickness: 1),
          _StatWidget(label: 'Più Lunga', value: longestStreak.toString(), color: _getColorForValue(longestStreak)),
          const VerticalDivider(thickness: 1),
          _StatWidget(label: 'Prima', value: firstStreak.toString(), color: _getColorForValue(firstStreak)),
        ],
      ),
    );
  }

  Color _getColorForValue(int value) {
    if (value >= 15) return Colors.red;
    if (value >= 10) return Colors.red[700]!;
    if (value >= 5) return Colors.orange[900]!;
    if (value > 0) return Colors.orange[300]!;
    return Colors.grey;
  }
}

class _StatWidget extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatWidget({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: context.textTheme.bodySmall,
        ),
        4.height,
        Text(
          value,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}

class _StreakItemWidget extends StatelessWidget {
  final Streak streak;
  final int number;

  const _StreakItemWidget({required this.streak, required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: context.containerDecoration.copyWith(
        border: Border.all(color: streak.getStreakColor().withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.local_fire_department, color: streak.getStreakColor(), size: 28),
              12.width,
              Text(
                'Streak #$number',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Text(
            '${streak.goodGrades} voti',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
