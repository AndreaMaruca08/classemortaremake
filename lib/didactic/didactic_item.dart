class DidacticItem {
  final String title;
  final String teacher;
  final int folderId;
  final int fileId;
  final DateTime date;

  DidacticItem({
    required this.title,
    required this.teacher,
    required this.folderId,
    required this.fileId,
    required this.date,
  });

  factory DidacticItem.fromJson(Map<String, dynamic> json, String title, String teacher, int folderId) {
    return DidacticItem(
      title: title,
      teacher: teacher,
      folderId: folderId,
      fileId: json['contentId'] ?? 0,
      date: DateTime.parse(json['shareDT']),
    );
  }
}
