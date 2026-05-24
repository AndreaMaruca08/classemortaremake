class HolidayPeriod {
  DateTime start;
  DateTime end;

  HolidayPeriod({
    required this.start,
    required this.end,
  });

  static List<HolidayPeriod> fromJson(Map<String, dynamic> json) {
    final daysDynamic = json["calendar"] as List<dynamic>? ?? [];
    List<Map<String, dynamic>> days = daysDynamic.map((e) => e as Map<String, dynamic>).toList();

    List<HolidayPeriod> periods = [];
    DateTime? startPeriod;

    for (int i = 0; i < days.length; i++) {
      Map<String, dynamic> day = days[i];
      String dayStatus = day["dayStatus"];
      DateTime dayDate = DateTime.parse(day["dayDate"]);

      if (dayStatus == "NW" && dayDate.weekday > 5) {
        continue;
      }

      if (dayStatus != "SD") {
        startPeriod ??= dayDate;
      } else {
        if (startPeriod != null) {
          DateTime endPeriod = i > 0 ? DateTime.parse(days[i - 1]["dayDate"]) : dayDate;
          periods.add(HolidayPeriod(start: startPeriod, end: endPeriod));
          startPeriod = null;
        }
      }
    }

    if (startPeriod != null && days.isNotEmpty) {
      periods.add(HolidayPeriod(start: startPeriod, end: DateTime.parse(days.last["dayDate"])));
    }
    return periods;
  }
}
