import 'dart:convert';
import '../core/api/http_client.dart';
import 'student_card.dart';

class StudentService {
  final HttpClient _client = HttpClient();

  Future<StudentCard?> fetchStudentCard() async {
    final endpoint = "students/${_client.numericCode}/card";
    final response = await _client.get(endpoint);

    if (response.statusCode == 200) {
      try {
        final json = jsonDecode(response.body);
        return StudentCard.fromJson(json['card'] ?? {});
      } catch (e) {
        print("Error parsing student card: $e");
        return null;
      }
    }
    return null;
  }
}
