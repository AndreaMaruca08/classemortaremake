import 'package:classemortaremake/core/extension/spacing_extension.dart';
import 'package:classemortaremake/core/extension/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'grade.dart';
import 'widgets/grade_circle.dart';

class GradeDetail extends StatelessWidget {
  final Grade grade;
  final Grade? previousGrade;
  final int animationMs;

  const GradeDetail({
    super.key,
    required this.grade,
    this.previousGrade,
    required this.animationMs,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettagli voto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Center(
              child: GradeCircle(
                grade: grade,
                previousGrade: previousGrade,
                size: 140,
                fontSize: 28,
                animationMs: animationMs,
              ),
            ),
            24.height,
            Container(
              padding: const EdgeInsets.all(20),
              decoration: context.containerDecoration,
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: "Data:",
                    value: _formatDate(grade.date),
                  ),
                  _DetailRow(
                    icon: Icons.access_time_outlined,
                    label: "Periodo:",
                    value: grade.period == 1 ? "1° quadrimestre" : "2° quadrimestre",
                  ),
                  _DetailRow(
                    icon: Icons.book_outlined,
                    label: "Materia:",
                    value: grade.subjectFullName,
                  ),
                  _DetailRow(
                    icon: Icons.description_outlined,
                    label: "Descrizione:",
                    value: grade.description.isEmpty ? "Nessuna descrizione" : grade.description,
                  ),
                  _DetailRow(
                    icon: Icons.category_outlined,
                    label: "Tipologia:",
                    value: grade.type,
                  ),
                  _DetailRow(
                    icon: Icons.person_outline,
                    label: "Docente:",
                    value: grade.teacherName.isEmpty ? "Docente sconosciuto" : grade.teacherName,
                  ),
                  if (previousGrade != null) ...[
                    const Divider(),
                    _ProgressSection(
                      currentGrade: grade,
                      previousGrade: previousGrade!,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return "";
    if (dateString.length == 4) return dateString;
    try {
      DateTime date = DateTime.parse(dateString.substring(0, 10));
      return DateFormat('EEE d MMM yyyy', 'it_IT').format(date);
    } catch (e) {
      return dateString;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: context.colorScheme.secondary),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (value.isNotEmpty)
                  Text(
                    value,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: valueColor,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  final Grade currentGrade;
  final Grade previousGrade;

  const _ProgressSection({
    required this.currentGrade,
    required this.previousGrade,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUp = currentGrade.value > previousGrade.value;
    final bool isNeutral = currentGrade.value == previousGrade.value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Progresso rispetto al precedente:",
            style: context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          12.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                previousGrade.value.toStringAsFixed(2),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Icon(
                  isUp ? Icons.trending_up : (isNeutral ? Icons.trending_neutral : Icons.trending_down),
                  size: 32,
                  color: isUp ? Colors.green : (isNeutral ? Colors.grey : Colors.red),
                ),
              ),
              Text(
                currentGrade.value.toStringAsFixed(2),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
