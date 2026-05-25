import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:mime/mime.dart';
import '../api/http_client.dart';

class FileService {
  final HttpClient _client = HttpClient();

  Future<void> downloadAndOpenFile({
    required String url,
    required String fileName,
  }) async {
    try {
      // Puliamo l'URL per assicurarci di non avere baseUrl doppie o slash di troppo
      String endpoint = url;
      if (url.startsWith('http')) {
        // Se è un URL completo, cerchiamo di estrarre la parte relativa
        if (url.contains(_client.baseUrl)) {
          endpoint = url.replaceFirst(_client.baseUrl, '');
        } else {
          // Se è un URL esterno, usiamo HttpClient.getExternal
          final response = await _client.getExternal(url);
          await _processResponse(response, fileName);
          return;
        }
      }
      
      // Rimuoviamo eventuale slash iniziale perché HttpClient.get lo aggiunge o gestisce la baseUrl
      if (endpoint.startsWith('/')) {
        endpoint = endpoint.substring(1);
      }
          
      final response = await _client.get(endpoint);
      await _processResponse(response, fileName);
    } catch (e) {
      print('FileService Error: $e');
      rethrow;
    }
  }

  Future<void> _processResponse(http.Response response, String fileName) async {
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      
      String extension = '.pdf';
      final contentType = response.headers['content-type'];
      if (contentType != null) {
        final mimeType = contentType.split(';').first.trim();
        final ext = extensionFromMime(mimeType);
        if (ext != null) {
          extension = '.$ext';
        }
      }

      final tempDir = await getTemporaryDirectory();
      final fullFileName = fileName.endsWith(extension) ? fileName : '$fileName$extension';
      final file = File('${tempDir.path}/$fullFileName');

      await file.writeAsBytes(bytes);

      if (await file.exists()) {
        await OpenFile.open(file.path);
      }
    } else {
      throw Exception('Errore download: ${response.statusCode}');
    }
  }
}
