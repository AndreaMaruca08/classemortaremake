class LessonHour {
  String subject;
  List<String> teachers;
  int hour;

  LessonHour({
    required this.subject,
    required this.teachers,
    required this.hour,
  });

  factory LessonHour.fromJson(Map<String, dynamic> json) {
    // If authors is a list, use it, otherwise use authorName
    List<String> teachersList = [];
    if (json['authors'] != null && json['authors'] is List) {
      teachersList = (json['authors'] as List).map((e) => e['authorName'].toString()).toList();
    } else {
      teachersList = [json['authorName'] ?? ""];
    }

    return LessonHour(
      subject: json['subjectDesc'] ?? "",
      teachers: teachersList,
      hour: json['evtHPos'] ?? 0,
    );
  }

  static List<LessonHour> fromJsonList(Map<String, dynamic> json) {
    final lessons = json['lessons'] as List<dynamic>? ?? [];
    return lessons.map<LessonHour>((jsonMap) => LessonHour.fromJson(jsonMap)).toList();
  }
}
