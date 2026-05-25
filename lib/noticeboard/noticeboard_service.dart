import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api/http_client.dart';
import '../core/services/file_service.dart';
import 'notice.dart';

class NoticeboardService {
  final HttpClient _client = HttpClient();
  final FileService _fileService = FileService();

  Future<List<List<Notice>>> fetchNoticeboard() async {
    final endpoint = "students/${_client.numericCode}/noticeboard";
    final response = await _client.get(endpoint);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      
      return [
        Notice.fromJsonList(json, 1), // Circolari
        Notice.fromJsonList(json, 2), // Variazioni orario
        Notice.fromJsonList(json, 3), // Variazioni aula
        Notice.fromJsonList(json, 4), // Altro
      ];
    } else {
      throw Exception("Failed to fetch notices");
    }
  }

  Future<String> readNoticeContent(int pubId, String evtCode) async {
    final String safeEvtCode = evtCode.isNotEmpty ? evtCode : "NTCL";
    // Use the exact path structure from original code
    final endpoint = "students/${_client.numericCode}/noticeboard/read/$safeEvtCode/$pubId/101";
    // Many Spaggiari endpoints for "read" status or detail require POST
    final response = await _client.post(endpoint);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      // Original code: return data["item"]["text"]
      return json['item']?['text'] ?? json['cntDetail'] ?? "Nessun contenuto disponibile";
    } else {
      return "Errore: ${response.statusCode}";
    }
  }

  Future<void> openNoticeFile(int pubId, String evtCode, int attachNum, String fileName) async {
    final String safeEvtCode = evtCode.isNotEmpty ? evtCode : "NTCL";
    
    // Step 1: Mark as read (mandatory for download to work)
    final readEndpoint = "students/${_client.numericCode}/noticeboard/read/$safeEvtCode/$pubId/101";
    final readResp = await _client.post(readEndpoint);
    print("Read status response: ${readResp.statusCode}");

    // Step 2: Download the file
    final downloadEndpoint = "students/${_client.numericCode}/noticeboard/attach/$safeEvtCode/$pubId/$attachNum";
    print("Attempting download: $downloadEndpoint");
    
    try {
      await _fileService.downloadAndOpenFile(
        url: downloadEndpoint,
        fileName: fileName,
      );
    } catch (e) {
      if (e.toString().contains('404')) {
        // Fallback: some versions of the API don't require the evtCode in the URL
        final fallbacks = [
          "students/${_client.numericCode}/noticeboard/attach/$pubId/$attachNum",
          "students/${_client.numericCode}/noticeboard/attach/NTCL/$pubId/$attachNum",
          "students/${_client.numericCode}/noticeboard/attach/NTWN/$pubId/$attachNum",
        ];
        
        for (var f in fallbacks) {
          try {
            print("Fallback attempt: $f");
            await _fileService.downloadAndOpenFile(url: f, fileName: fileName);
            return;
          } catch (_) {}
        }
      }
      rethrow;
    }
  }
}
