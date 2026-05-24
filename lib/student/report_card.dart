import 'package:http/http.dart' as http;

class ReportCard {
  String title;
  String html;

  ReportCard({
    required this.title,
    required this.html,
  });

  static Future<ReportCard> fromJson(Map<String, dynamic> json) async {
    return ReportCard(
      title: json['desc'] ?? "",
      html: await getHtml(json['viewLink'] ?? ""),
    );
  }

  static Future<String> getHtml(String url) async {
    if (url.isEmpty) return "";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return "";
    }
  }

  static Future<List<ReportCard>> fromJsonList(List<dynamic> json) async {
    List<ReportCard> reportCards = [];
    for (var item in json) {
      reportCards.add(await fromJson(item));
    }
    return reportCards;
  }
}
