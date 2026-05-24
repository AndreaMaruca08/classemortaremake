class Note {
  int id;
  String message;
  String date;
  String author;
  bool isRead;

  Note({
    required this.id,
    required this.message,
    required this.date,
    required this.author,
    required this.isRead,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['evtId'] ?? 0,
      message: json['evtText'] ?? "",
      date: json['evtDate'] ?? "",
      author: json['authorName'] ?? "",
      isRead: json['readStatus'] ?? false,
    );
  }

  static List<List<Note>> getNotes(Map<String, dynamic> json) {
    List<Note> annotations = [];
    List<Note> notices = [];
    List<Note> disciplinary = [];
    List<Note> classNotes = [];
    
    final annotationsJson = json['NTTE'] as List<dynamic>?;
    final disciplinaryJson = json["NTCL"] as List<dynamic>?;
    final classNotesJson = json["NTST"] as List<dynamic>?;
    final noticesJson = json["NTWN"] as List<dynamic>?;

    if (annotationsJson != null) {
      annotations = annotationsJson.map<Note>((item) => Note.fromJson(item)).toList();
    }
    if (noticesJson != null) {
      notices = noticesJson.map<Note>((item) => Note.fromJson(item)).toList();
    }
    if (disciplinaryJson != null) {
      disciplinary = disciplinaryJson.map<Note>((item) => Note.fromJson(item)).toList();
    }
    if (classNotesJson != null) {
      classNotes = classNotesJson.map<Note>((item) => Note.fromJson(item)).toList();
    }

    return [
      disciplinary.reversed.toList(),
      annotations.reversed.toList(),
      classNotes.reversed.toList(),
      notices.reversed.toList()
    ];
  }
}
