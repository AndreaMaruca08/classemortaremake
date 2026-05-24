import 'package:classemortaremake/core/extension/spacing_extension.dart';
import 'package:classemortaremake/core/extension/theme_extension.dart';
import 'package:classemortaremake/grades/grade.dart';
import 'package:classemortaremake/grades/grade_service.dart';
import 'package:classemortaremake/grades/subject.dart';
import 'package:classemortaremake/grades/subject_detail_page.dart';
import 'package:classemortaremake/grades/widgets/grade_circle.dart';
import 'package:flutter/material.dart';

class SubjectCard extends StatelessWidget {
  final Subject subject;
  final int animationMs;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.animationMs,
  });

  @override
  Widget build(BuildContext context) {
    final averages = GradeService.getSubjectAverages(subject);
    final sortedGrades = List<Grade>.from(subject.grades)
      ..sort((a, b) => b.date.compareTo(a.date));

    Grade? lastGrade;
    Grade? secondLastGrade;
    if (sortedGrades.isNotEmpty) {
      lastGrade = sortedGrades[0];
      if (sortedGrades.length > 1) {
        secondLastGrade = sortedGrades[1];
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: context.containerDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  subject.subjectFullName,
                  style: context.textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              12.width,
              Text(
                subject.teacherName,
                style: context.textTheme.bodySmall,
                textAlign: TextAlign.end,
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _AverageColumn(
                title: "Totale",
                grade: averages[0],
                subject: subject,
                animationMs: animationMs,
              ),
              _AverageColumn(
                title: "1° Quad",
                grade: averages[1],
                subject: subject,
                animationMs: animationMs,
              ),
              _AverageColumn(
                title: "2° Quad",
                grade: averages[2],
                subject: subject,
                animationMs: animationMs,
              ),
            ],
          ),
          if (lastGrade != null && secondLastGrade != null) ...[
            const Divider(height: 24),
            _TrendInfo(
              last: lastGrade,
              previous: secondLastGrade,
            ),
          ],
        ],
      ),
    );
  }
}

class _AverageColumn extends StatelessWidget {
  final String title;
  final Grade grade;
  final Subject subject;
  final int animationMs;

  const _AverageColumn({
    required this.title,
    required this.grade,
    required this.subject,
    required this.animationMs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        8.height,
        GradeCircle(
          grade: grade,
          size: 90,
          fontSize: 17,
          animationMs: animationMs,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubjectDetailPage(
                  subject: subject,
                  period: grade.period,
                  dotted: true,
                  animationMs: animationMs,
                ),
              ),
            );
          },
        ),
        8.height
      ],
    );
  }
}

class _TrendInfo extends StatelessWidget {
  final Grade last;
  final Grade previous;

  const _TrendInfo({required this.last, required this.previous});

  @override
  Widget build(BuildContext context) {
    final diff = last.value - previous.value;
    final isUp = diff > 0;
    final isEqual = diff == 0;

    return Row(
      children: [
        Icon(
          isUp
              ? Icons.arrow_upward
              : (isEqual ? Icons.trending_neutral : Icons.arrow_downward),
          color: isUp ? Colors.green : (isEqual ? Colors.grey : Colors.red),
          size: 20,
        ),
        4.width,
        Text(
          "${isUp ? "Aumento di" : (isEqual ? "Stabile" : "Calo di")}: ${diff.abs().toStringAsFixed(2)}",
          style: const TextStyle(fontSize: 13),
        ),
        const Spacer(),
        Text(
          "Ultimo: ${last.value}",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: GradeService.getGradeColor(last.value),
          ),
        ),
      ],
    );
  }
}
