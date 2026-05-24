class Attendance {
  String date;
  bool isJustified;
  String justification;
  String type;

  Attendance({
    required this.date,
    required this.isJustified,
    required this.justification,
    required this.type,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      date: json['evtDate'] ?? "",
      isJustified: json['isJustified'] ?? false,
      justification: json['justifReasonDesc'] ?? "",
      type: json['evtCode'] ?? "",
    );
  }

  static List<Attendance> fromJsonList(Map<String, dynamic> json, String type) {
    final events = json["events"] as List<dynamic>? ?? [];
    List<Attendance> attendances =
        events.map<Attendance>((jsonMap) => Attendance.fromJson(jsonMap)).toList();

    return attendances.where((a) => a.type == type).toList();
  }

  static List<Attendance> forAchievement(List<dynamic> eventsList, String type) {
    List<Attendance> allAttendances = eventsList
        .map<Attendance>((jsonMap) => Attendance.fromJson(jsonMap))
        .toList();

    return allAttendances.where((a) => a.type == type).toList();
  }
}
