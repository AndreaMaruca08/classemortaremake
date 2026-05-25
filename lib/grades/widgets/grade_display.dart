import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../grade.dart';
import 'grade_circle.dart';

class GradeDisplay extends StatelessWidget {
  final Grade grade;
  final Grade? previousGrade;
  final int animationMs;
  final double size;

  const GradeDisplay({
    super.key,
    required this.grade,
    this.previousGrade,
    required this.size,
    required this.animationMs,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          GradeCircle(
            grade: grade,
            previousGrade: previousGrade,
            size: size,
            fontSize: size * 0.25,
            animationMs: animationMs,
            showDetailOnTap: true,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  grade.subjectCode,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${_formatDate(grade.date)} | ${_truncate(grade.subjectFullName, 20)}",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                if (grade.description.isNotEmpty)
                  Text(
                    grade.description,
                    style:
                        const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      if (dateString.length < 10) return dateString;
      DateTime date = DateTime.parse(dateString.substring(0, 10));
      return DateFormat('EEE d MMM yyyy', 'it_IT').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _truncate(String text, int length) {
    if (text.length <= length) return text;
    return "${text.substring(0, length)}...";
  }
}
