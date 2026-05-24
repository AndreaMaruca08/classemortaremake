import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'grade.dart';
import 'subject.dart';

class GradeService {
  static List<Grade> getGeneralAverages(List<Grade> grades) {
    double totalSum = 0.0;
    double p1Sum = 0.0;
    double p2Sum = 0.0;
    int totalCount = 0;
    int p1Count = 0;
    int p2Count = 0;

    for (Grade grade in grades) {
      if (grade.isCanceled ||
          grade.value == 0.0 ||
          grade.subjectCode.toUpperCase() == "REL" ||
          grade.subjectFullName.toUpperCase() == "RELIGIONE") {
        continue;
      }

      totalSum += grade.value;
      totalCount++;

      if (grade.period == 1) {
        p1Sum += grade.value;
        p1Count++;
      } else if (grade.period == 2) {
        p2Sum += grade.value;
        p2Count++;
      }
    }

    double totalAverage = totalCount > 0 ? totalSum / totalCount : 0.0;
    double p1Average = p1Count > 0 ? p1Sum / p1Count : 0.0;
    double p2Average = p2Count > 0 ? p2Sum / p2Count : 0.0;

    return [
      Grade(
        subjectCode: "Tot",
        subjectFullName: "Media totale",
        date: "${DateTime.now().year}",
        value: totalAverage,
        displayValue: totalAverage.toStringAsFixed(3),
        description: "Media Totale dell'anno",
        period: 3,
        isCanceled: false,
        teacherName: "Sistema",
        type: "average",
      ),
      Grade(
        subjectCode: "1°",
        subjectFullName: "Media primo quadrimestre",
        date: "${DateTime.now().year}",
        value: p1Average,
        displayValue: p1Average.toStringAsFixed(2),
        description: "Media del primo quadrimestre",
        period: 1,
        isCanceled: false,
        teacherName: "Sistema",
        type: "average",
      ),
      Grade(
        subjectCode: "2°",
        subjectFullName: "Media secondo quadrimestre",
        date: "${DateTime.now().year}",
        value: p2Average,
        displayValue: p2Average.toStringAsFixed(2),
        description: "Media del secondo quadrimestre",
        period: 2,
        isCanceled: false,
        teacherName: "Sistema",
        type: "average",
      ),
    ];
  }

  static List<Grade> getSubjectAverages(Subject subject) {
    final grades = subject.grades;
    double totalSum = 0.0;
    double p1Sum = 0.0;
    double p2Sum = 0.0;
    int totalCount = 0;
    int p1Count = 0;
    int p2Count = 0;

    for (Grade grade in grades) {
      if (grade.isCanceled || grade.value == 0) continue;

      totalSum += grade.value;
      totalCount++;

      if (grade.period == 1) {
        p1Sum += grade.value;
        p1Count++;
      } else if (grade.period == 2) {
        p2Sum += grade.value;
        p2Count++;
      }
    }

    double totalAvg = totalCount > 0 ? totalSum / totalCount : 0.0;
    double p1Avg = p1Count > 0 ? p1Sum / p1Count : 0.0;
    double p2Avg = p2Count > 0 ? p2Sum / p2Count : 0.0;

    return [
      Grade(
        subjectCode: "Tot",
        subjectFullName: "Media totale di ${subject.subjectFullName}",
        date: "${DateTime.now().year}",
        value: totalAvg,
        displayValue: totalAvg.toStringAsFixed(3),
        description: "Media totale della materia",
        period: 3,
        isCanceled: false,
        teacherName: "Sistema",
        type: "average",
      ),
      Grade(
        subjectCode: "1°",
        subjectFullName: "Media 1° quadrimestre di ${subject.subjectFullName}",
        date: "${DateTime.now().year}",
        value: p1Avg,
        displayValue: p1Avg.toStringAsFixed(2),
        description: "Media del primo quadrimestre",
        period: 1,
        isCanceled: false,
        teacherName: "Sistema",
        type: "average",
      ),
      Grade(
        subjectCode: "2°",
        subjectFullName: "Media 2° quadrimestre di ${subject.subjectFullName}",
        date: "${DateTime.now().year}",
        value: p2Avg,
        displayValue: p2Avg.toStringAsFixed(2),
        description: "Media del secondo quadrimestre",
        period: 2,
        isCanceled: false,
        teacherName: "Sistema",
        type: "average",
      ),
    ];
  }

  static List<Subject> getSubjectsFromGrades(List<Grade> grades) {
    Map<String, List<Grade>> subjectsMap = {};
    for (var grade in grades) {
      if (grade.isCanceled || grade.value == 0) continue;
      subjectsMap.putIfAbsent(grade.subjectCode, () => []).add(grade);
    }

    return subjectsMap.entries.map((e) {
      final subjectGrades = e.value;
      return Subject(
        subjectCode: e.key,
        subjectFullName: subjectGrades.first.subjectFullName,
        teacherName: subjectGrades.first.teacherName,
        grades: subjectGrades,
      );
    }).toList();
  }

  static List<Grade> calculateProgressiveAverages(List<Grade> grades) {
    double sum = 0;
    int count = 0;
    List<Grade> progressive = [];

    for (Grade g in grades) {
      if (g.isCanceled) continue;
      sum += g.value;
      count++;
      double average = sum / count;

      progressive.add(Grade(
        subjectCode: g.subjectCode,
        subjectFullName: g.subjectFullName,
        date: g.date,
        value: average,
        displayValue: average.toStringAsFixed(2),
        description: "Media progressiva",
        period: g.period,
        type: "average",
        isCanceled: false,
        teacherName: g.teacherName,
      ));
    }
    return progressive;
  }

  static double calculateConsistency(double average, List<Grade> grades) {
    final validGrades = grades.where((g) => !g.isCanceled).toList();
    if (validGrades.isEmpty || average == 0) return 0;

    double sumSquaredDiff = 0;
    for (var g in validGrades) {
      sumSquaredDiff += math.pow(g.value - average, 2);
    }

    double variance = sumSquaredDiff / validGrades.length;
    double stdDev = math.sqrt(variance);
    double consistency = 100 - ((stdDev / average) * 100);

    return consistency.clamp(0, 100);
  }

  static double getAverage(List<Grade> grades) {
    final validGrades =
        grades.where((g) => !g.isCanceled && g.value > 0).toList();
    if (validGrades.isEmpty) return 0.0;

    double sum = 0.0;
    for (var g in validGrades) {
      sum += g.value;
    }
    return sum / validGrades.length;
  }

  static Color getGradeColor(double value) {
    if (value >= 6.0) return Colors.green;
    if (value >= 5.0) return Colors.yellow;
    return Colors.red;
  }

  static List<Color> getGradeGradient(double value) {
    if (value >= 6.0) {
      return [Colors.green, const Color.fromRGBO(30, 100, 30, 1)];
    } else if (value >= 5.0) {
      return [Colors.yellow, const Color.fromRGBO(100, 100, 30, 1)];
    } else {
      return [Colors.red, const Color.fromRGBO(100, 30, 30, 1)];
    }
  }
}
