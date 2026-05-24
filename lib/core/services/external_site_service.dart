import 'package:url_launcher/url_launcher.dart';
import '../api/http_client.dart';

class ExternalSiteService {
  final HttpClient _client = HttpClient();

  Future<void> launchRegistryWeb() async {
    try {
      String sid = await _client.fetchPhpSessId();
      final String identity = _client.studentCode ?? '';
      final Uri url = Uri.parse('https://web.spaggiari.eu/home/app/default/menu.php');

      bool launched = await launchUrl(
        url,
        mode: LaunchMode.inAppBrowserView,
        webViewConfiguration: WebViewConfiguration(
          enableJavaScript: true,
          enableDomStorage: true,
          headers: {
            'User-Agent':
                'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1',
            'Cookie': 'PHPSESSID=$sid; webrole=gen; webidentity=$identity',
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Upgrade-Insecure-Requests': '1',
          },
        ),
      );

      if (!launched) {
        throw 'Could not launch URL';
      }
    } catch (e) {
      rethrow;
    }
  }
}
