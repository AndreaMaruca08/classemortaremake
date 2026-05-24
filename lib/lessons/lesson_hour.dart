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
    return LessonHour(
      subject: json['subjectDesc'] ?? "",
      teachers: [json['authorName'] ?? ""],
      hour: json['evtHPos'] ?? 0,
    );
  }

  static List<LessonHour> fromJsonList(Map<String, dynamic> json) {
    final lessons = json['lessons'] as List<dynamic>? ?? [];
    return lessons.map<LessonHour>((jsonMap) => LessonHour.fromJson(jsonMap)).toList();
  }
}
