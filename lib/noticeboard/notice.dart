import '../../didactic/attach.dart';

class Notice {
  int documentId;
  bool hasFile;
  String eventCode;
  String title;
  bool isRead;
  String insertionDate;
  List<Attach> attachments;

  Notice({
    required this.documentId,
    required this.hasFile,
    required this.eventCode,
    required this.title,
    required this.isRead,
    required this.insertionDate,
    required this.attachments,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      documentId: json['pubId'] ?? 0,
      hasFile: json['cntHasAttach'] ?? false,
      eventCode: json['evtCode'] ?? "",
      title: json['cntTitle'] ?? "",
      isRead: json['readStatus'] ?? false,
      insertionDate: json['dinsert_allegato'] ?? "",
      attachments: Attach.fromJsonList(json),
    );
  }

  static List<Notice> fromJsonList(Map<String, dynamic> json, int type) {
    final items = json['items'] as List<dynamic>? ?? [];
    Iterable<dynamic> filteredItems = [];

    if (type == 1) {
      filteredItems = items.where((item) {
        String title = (item['cntTitle'] ?? "").toString().toLowerCase();
        return title.contains("circ");
      });
    } else if (type == 2) {
      filteredItems = items.where((item) {
        String title = (item['cntTitle'] ?? "").toString().toLowerCase();
        return title.contains("variazione d'orario") ||
            title.contains("variazioni orario") ||
            title.contains("assenza");
      });
    } else if (type == 3) {
      filteredItems = items.where((item) {
        String title = (item['cntTitle'] ?? "").toString().toLowerCase();
        return title.contains("variazioni di aula");
      });
    } else if (type == 4) {
      filteredItems = items.where((item) {
        String title = (item['cntTitle'] ?? "").toString().toLowerCase();
        return !title.contains("circ") &&
            !title.contains("variazione d'orario") &&
            !title.contains("variazioni di aula") &&
            !title.contains("variazioni orario") &&
            !title.contains("assenza");
      });
    }

    return filteredItems
        .map<Notice>((jsonMap) => Notice.fromJson(jsonMap))
        .toList();
  }
}
