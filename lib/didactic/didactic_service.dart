import 'dart:convert';
import '../core/api/http_client.dart';
import '../core/services/file_service.dart';
import 'didactic_item.dart';

class DidacticService {
  final HttpClient _client = HttpClient();
  final FileService _fileService = FileService();

  Future<List<DidacticItem>> fetchDidactics() async {
    final endpoint = "students/${_client.numericCode}/didactics";
    final response = await _client.get(endpoint);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<DidacticItem> items = [];

      for (var teacher in data['didacticts']) {
        final teacherName = teacher['teacherName'] ?? '';

        for (var folder in teacher['folders']) {
          final folderId = folder['folderId'];
          final folderName = folder['folderName'] ?? '';

          for (var content in folder['contents']) {
            items.add(DidacticItem.fromJson(content, folderName, teacherName, folderId));
          }
        }
      }

      items.sort((a, b) => b.date.compareTo(a.date));
      return items;
    } else {
      throw Exception("Failed to fetch didactic files: ${response.statusCode}");
    }
  }

  Future<void> downloadDidacticFile(DidacticItem item) async {
    final endpoint = "students/${_client.numericCode}/didactics/item/${item.fileId}";
    
    await _fileService.downloadAndOpenFile(
      url: endpoint,
      fileName: item.title,
    );
  }
}
