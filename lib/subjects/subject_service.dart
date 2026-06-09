import 'dart:convert';
import '../core/api/http_client.dart';
import 'subject_teacher.dart';

class SubjectTeacherService {
  final HttpClient _client = HttpClient();

  Future<List<SubjectTeacher>> fetchSubjects() async {
    final endpoint = "students/${_client.numericCode}/subjects";
    final response = await _client.get(endpoint);

    if (response.statusCode == 200) {
      try {
        final json = jsonDecode(response.body);
        return SubjectTeacher.fromJsonList(json);
      } catch (e) {
        print("Error parsing subjects: $e");
        return [];
      }
    }
    return [];
  }
}
