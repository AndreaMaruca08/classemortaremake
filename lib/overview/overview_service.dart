import 'dart:convert';
import '../core/api/http_client.dart';
import 'models/overview_data.dart';

class OverviewService {
  final HttpClient _client = HttpClient();

  Future<OverviewData?> fetchOverview() async {
    final dateRange = _getDateRange(yearsBack: _client.isPreviousYear ? 2 : 0);
    final endpoint = "students/${_client.numericCode}/overview/all/$dateRange";

    final response = await _client.get(endpoint);

    if (response.statusCode == 200) {
      try {
        final json = jsonDecode(response.body);
        return OverviewData.fromJson(json);
      } catch (e) {
        print("Error parsing overview data: $e");
        return null;
      }
    } else {
      print("Failed to fetch overview: ${response.statusCode}");
      return null;
    }
  }

  String _getDateRange({int yearsBack = 0}) {
    DateTime now = DateTime.now();
    int year = now.year - yearsBack;
    int month = now.month;
    int yearStart = year;

    if (month < 9) {
      yearStart--;
    }

    int yearEnd = yearStart + 1;
    return "${yearStart}0901/${yearEnd}0831";
  }
}
