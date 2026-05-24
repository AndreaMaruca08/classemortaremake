class Grade {
  String subjectCode;
  String subjectFullName;
  String date;
  double value;
  String displayValue;
  String description;
  int period;
  String type;
  bool isCanceled;
  String teacherName;

  Grade({
    required this.subjectCode,
    required this.subjectFullName,
    required this.date,
    required this.value,
    required this.displayValue,
    required this.description,
    required this.period,
    required this.type,
    required this.isCanceled,
    required this.teacherName,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      subjectCode: json['subjectCode'] ?? "",
      subjectFullName: json['subjectDesc'] ?? "",
      date: json['evtDate'] ?? "",
      value: json['decimalValue'] == null ? 0.0 : json['decimalValue'].toDouble(),
      displayValue: json['displayValue'] ?? '',
      description: json['notesForFamily'] ?? "",
      period: json['periodPos'] == 3 ? 2 : json['periodPos'],
      type: json['componentDesc'] ?? "",
      isCanceled: json['canceled'] ?? false,
      teacherName: json['teacherName'] ?? "",
    );
  }

  static List<Grade> fromJsonList(Map<String, dynamic> json) {
    final grades = json['grades'] as List<dynamic>? ?? [];
    return grades.map<Grade>((item) => Grade.fromJson(item)).toList();
  }

  static List<Grade> forAchievement(List<dynamic> gradesList) {
    var grades = gradesList.map<Grade>((jsonMap) => Grade.fromJson(jsonMap)).toList();
    List<Grade> sortableGrades = List<Grade>.from(grades);

    sortableGrades.sort((a, b) {
      bool aIsValid = a.date.length == 10;
      bool bIsValid = b.date.length == 10;
      if (aIsValid && !bIsValid) return -1;
      if (!aIsValid && bIsValid) return 1;
      if (!aIsValid && !bIsValid) return 0;
      return b.date.compareTo(a.date);
    });
    return sortableGrades;
  }
}
