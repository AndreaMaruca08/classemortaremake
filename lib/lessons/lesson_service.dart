import 'dart:convert';
import '../core/api/http_client.dart';
import 'lesson_hour.dart';

class LessonService {
  final HttpClient _client = HttpClient();

  Future<List<LessonHour>> getTodayLessons() async {
    final endpoint = "students/${_client.numericCode}/lessons/today";
    final response = await _client.get(endpoint);
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return LessonHour.fromJsonList(json);
    } else {
      return [];
    }
  }

  Future<List<LessonHour>> getLessonsForDate(DateTime date) async {
    final String dateStr = "${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}";
    final endpoint = "students/${_client.numericCode}/lessons/$dateStr";
    final response = await _client.get(endpoint);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return LessonHour.fromJsonList(json);
    } else {
      return [];
    }
  }
}
