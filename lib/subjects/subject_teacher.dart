class SubjectTeacher {
  final int id;
  final String description;
  final int order;
  final List<Teacher> teachers;

  SubjectTeacher({
    required this.id,
    required this.description,
    required this.order,
    required this.teachers,
  });

  factory SubjectTeacher.fromJson(Map<String, dynamic> json) {
    return SubjectTeacher(
      id: json['id'] ?? 0,
      description: json['description'] ?? "",
      order: json['order'] ?? 0,
      teachers: (json['teachers'] as List? ?? [])
          .map((t) => Teacher.fromJson(t))
          .toList(),
    );
  }

  static List<SubjectTeacher> fromJsonList(Map<String, dynamic> json) {
    final list = json['subjects'] as List? ?? [];
    return list.map((item) => SubjectTeacher.fromJson(item)).toList();
  }
}

class Teacher {
  final String id;
  final String name;

  Teacher({required this.id, required this.name});

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['teacherId'] ?? "",
      name: json['teacherName'] ?? "",
    );
  }
}
