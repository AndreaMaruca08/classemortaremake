import 'dart:convert';
import '../core/api/http_client.dart';
import 'holiday_period.dart';

class HolidayService {
  final HttpClient _client = HttpClient();

  Future<List<HolidayPeriod>> fetchHolidays() async {
    final endpoint = "students/${_client.numericCode}/calendar/all";
    final response = await _client.get(endpoint);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return HolidayPeriod.fromJson(json);
    } else {
      throw Exception("Failed to fetch calendar data: ${response.statusCode}");
    }
  }
}
