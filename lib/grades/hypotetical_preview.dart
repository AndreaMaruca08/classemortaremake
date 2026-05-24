import 'package:flutter/material.dart';
import 'package:classemortaremake/grades/widgets/grade_circle.dart';
import 'package:classemortaremake/grades/grade.dart';
import 'grade.dart';

class HypotheticalPreview extends StatelessWidget {
  final List<Grade> grades;
  final int animationMs;

  const HypotheticalPreview({
    super.key,
    required this.grades,
    required this.animationMs,
  });

  double _calculateAverage(List<Grade> gradeList) {
    if (gradeList.isEmpty) return 0.0;
    double sum = 0.0;
    int validCount = 0;
    for (Grade grade in gradeList) {
      if (grade.isCanceled) continue;
      sum += grade.value;
      validCount++;
    }
    return validCount == 0 ? 0.0 : sum / validCount;
  }

  List<Widget> _generateHypotheticalRows() {
    List<Widget> rows = [];

    rows.add(
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Se prendi ↓",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "Media diventa ↓",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );

    for (int i = 0; i <= 20; i++) {
      double nextGradeValue = (i * 0.5);
      List<Grade> temporaryGrades = List.from(grades);

      Grade hypotheticalGrade = Grade(
        subjectCode: grades.isNotEmpty ? grades[0].subjectCode : "",
        subjectFullName: grades.isNotEmpty ? grades[0].subjectFullName : "",
        date: DateTime.now().toIso8601String(),
        value: nextGradeValue,
        displayValue: nextGradeValue.toStringAsFixed(1),
        description: "Voto ipotetico",
        period: 1,
        type: "Voto ipotetico",
        isCanceled: false,
        teacherName: grades.isNotEmpty ? grades[0].teacherName : "",
      );
      temporaryGrades.add(hypotheticalGrade);

      double calculatedAverage = _calculateAverage(temporaryGrades);

      Grade displayGrade = Grade(
        subjectCode: "",
        subjectFullName: "",
        date: "",
        value: calculatedAverage,
        displayValue: calculatedAverage.toStringAsFixed(2),
        description: "",
        period: 0,
        type: "",
        isCanceled: false,
        teacherName: "",
      );

      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  nextGradeValue.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
              GradeCircle(
                grade: displayGrade,
                size: 70,
                fontSize: 17,
                animationMs: animationMs,
              ),
            ],
          ),
        ),
      );
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    if (grades.isEmpty) {
      return const Center(
        child: Text("Nessun voto per calcolare medie ipotetiche."),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(240, 240, 240, 0.2),
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _generateHypotheticalRows(),
      ),
    );
  }
}