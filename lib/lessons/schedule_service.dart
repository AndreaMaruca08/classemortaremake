import 'dart:convert';
import '../core/api/http_client.dart';
import 'lesson_hour.dart';
import 'day.dart';

class ScheduleService {
  final HttpClient _client = HttpClient();

  Future<List<List<Day>>> fetchTwoWeeksSchedule() async {
    final now = DateTime.now();
    final int weekday = now.weekday;
    
    final today = DateTime(now.year, now.month, now.day);
    // Monday of this week
    final mondayThisWeek = today.subtract(Duration(days: weekday - 1));

    final int schoolYearStartYear = now.month >= 9 ? now.year : now.year - 1;
    final schoolYearStart = DateTime(schoolYearStartYear, 9, 1);

    DateTime startRange = mondayThisWeek.subtract(const Duration(days: 28));
    if (startRange.isBefore(schoolYearStart)) {
      startRange = schoolYearStart;
    }

    final endRange = mondayThisWeek.add(const Duration(days: 4));
    if (startRange.isAfter(endRange)) {
      startRange = endRange;
    }

    final startStr = _formatDate(startRange);
    final endStr = _formatDate(endRange);
    
    final endpoint = "students/${_client.numericCode}/lessons/$startStr/$endStr";
    final response = await _client.get(endpoint);

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch lessons range");
    }

    final json = jsonDecode(response.body);
    final List<dynamic> allLessons = json['lessons'] ?? [];
    
    // Group all lessons by date
    final Map<String, List<LessonHour>> lessonsByDate = {};
    for (var l in allLessons) {
      final hour = LessonHour.fromJson(l);
      final date = l['evtDate'] as String;
      lessonsByDate.putIfAbsent(date, () => []).add(hour);
    }

    // Processed weeks: week1 is current week, week2 is previous week
    final List<Day> week1 = _buildWeek(mondayThisWeek, lessonsByDate);
    final List<Day> week2 = _buildWeek(mondayThisWeek.subtract(const Duration(days: 7)), lessonsByDate);

    final bool week2Empty = week2.every((d) => d.hours.isEmpty);
    return [week1, week2Empty ? week1 : week2];
  }

  List<Day> _buildWeek(DateTime monday, Map<String, List<LessonHour>> data) {
    List<Day> week = [];
    
    // Identify potential support teachers across the entire dataset to filter them out
    final Set<String> supportTeachers = {};
    for (var lessons in data.values) {
      for (var l in lessons) {
        if (l.subject.toUpperCase() == "SOSTEGNO") {
          supportTeachers.addAll(l.teachers);
        }
      }
    }

    for (int i = 0; i < 5; i++) {
      final targetDate = monday.add(Duration(days: i));
      final List<LessonHour> finalHours = [];
      
      // Attempt to reconstruct each hour (1 to 8)
      for (int hNum = 1; hNum <= 8; hNum++) {
        LessonHour? hourData = _findBestMatchForHour(targetDate, hNum, data, supportTeachers);
        if (hourData != null) {
          finalHours.add(hourData);
        }
      }
      
      week.add(Day(hours: finalHours));
    }
    return week;
  }

  LessonHour? _findBestMatchForHour(DateTime date, int hourNum, Map<String, List<LessonHour>> data, Set<String> supportTeachers) {
    // Search current week, then -1, -2, -3
    for (int weekOffset = 0; weekOffset <= 3; weekOffset++) {
      final checkDate = date.subtract(Duration(days: 7 * weekOffset));
      final dateStr = _formatDateWithDashes(checkDate);
      final lessons = data[dateStr];
      
      if (lessons != null) {
        final matches = lessons.where((l) => 
          l.hour == hourNum && 
          l.subject.toUpperCase() != "SOSTEGNO" &&
          !l.teachers.any((t) => supportTeachers.contains(t))
        ).toList();

        if (matches.isNotEmpty) {
          // Found it! Merge teachers if there are multiple entries for the same hour
          final first = matches.first;
          final allTeachers = matches.expand((m) => m.teachers).toSet().toList();
          return LessonHour(
            subject: first.subject,
            teachers: allTeachers,
            hour: hourNum,
            description: first.description,
          );
        }
      }
    }
    return null;
  }

  String _formatDate(DateTime d) => 
      "${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}";

  String _formatDateWithDashes(DateTime d) => 
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
}
