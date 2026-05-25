import '../core/api/http_client.dart';
import 'curriculum_data.dart';

class CurriculumService {
  final HttpClient _client = HttpClient();

  Future<CurriculumData> getCurriculum() async {
    try {
      // Step 1: Ensure we have a fresh PHPSESSID
      String sid = await _client.fetchPhpSessId();
      final String identity = _client.studentCode ?? '';

      // Step 2: Fetch the curriculum page with the required cookies
      final url = "https://web.spaggiari.eu/set/app/default/curriculum.php?";
      final headers = {
        'User-Agent': 'Mozilla/5.0',
        'Cookie': 'PHPSESSID=$sid; webrole=gen; webidentity=$identity',
      };

      final response = await _client.getExternal(url, headers: headers);
      
      if (response.statusCode == 200) {
        final curriculumData = parseCurriculumHtml(response.body, sid);
        if (curriculumData == null) {
          throw Exception('Errore durante il parsing del curriculum');
        }
        return curriculumData;
      } else {
        throw Exception('Impossibile caricare il curriculum: ${response.statusCode}');
      }
    } catch (e) {
      print('CurriculumService Error: $e');
      rethrow;
    }
  }
}
