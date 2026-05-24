import 'dart:convert';
import '../core/api/http_client.dart';
import 'models/overview_data.dart';

class OverviewService {
  static final OverviewService _instance = OverviewService._internal();
  factory OverviewService() => _instance;
  OverviewService._internal();

  final HttpClient _client = HttpClient();
  OverviewData? _cachedData;

  OverviewData? get lastData => _cachedData;

  Future<OverviewData?> fetchOverview({bool forceRefresh = false}) async {
    if (_cachedData != null && !forceRefresh) {
      return _cachedData;
    }

    final dateRange = _getDateRange(yearsBack: _client.isPreviousYear ? 2 : 0);
    final endpoint = "students/${_client.numericCode}/overview/all/$dateRange";

    final response = await _client.get(endpoint);

    if (response.statusCode == 200) {
      try {
        final json = jsonDecode(response.body);
        _cachedData = OverviewData.fromJson(json);
        return _cachedData;
      } catch (e) {
        print("Error parsing overview data: $e");
        return null;
      }
    } else {
      print("Failed to fetch overview: ${response.statusCode}");
      return null;
    }
  }

  void clearCache() {
    _cachedData = null;
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
