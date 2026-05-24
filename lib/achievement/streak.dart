import 'package:flutter/material.dart';
import '../../grades/grade.dart';

class Streak {
  int goodGrades;
  bool isActive;

  Streak({
    this.goodGrades = 0,
    this.isActive = false,
  });

  Color getStreakColor() {
    if (isActive) {
      if (goodGrades >= 10) {
        return Colors.red[900]!;
      } else if (goodGrades >= 5) {
        return Colors.orange[900]!;
      } else {
        return Colors.orange[300]!;
      }
    } else {
      return Colors.grey;
    }
  }

  bool isGoated(List<Grade> initialGrades) {
    return initialGrades.length == goodGrades;
  }

  Streak getStreak(List<Grade> grades) {
    int streak = 0;
    bool isActive = false;
    for (Grade grade in grades) {
      if (grade.isCanceled) {
        continue;
      }
      if (grade.value >= 6) {
        streak++;
      } else {
        streak = 0;
      }
    }

    if (streak >= 2) {
      isActive = true;
    }
    return Streak(goodGrades: streak, isActive: isActive);
  }

  static List<Streak> getAllStreaks(List<Grade> grades) {
    final List<Streak> allStreaks = [];
    int currentStreak = 0;

    final validGrades = grades.where((grade) => !grade.isCanceled).toList();

    for (int i = 0; i < validGrades.length; i++) {
      Grade grade = validGrades[i];

      if (grade.value >= 6) {
        currentStreak++;
      }

      bool isInterrupted = grade.value < 6;
      bool isEndOfList = i == validGrades.length - 1;

      if ((isInterrupted || isEndOfList) && currentStreak >= 2) {
        allStreaks.add(Streak(goodGrades: currentStreak, isActive: true));
      }

      if (isInterrupted) {
        currentStreak = 0;
      }
    }

    return allStreaks;
  }
}
