import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  factory HttpClient() => _instance;
  HttpClient._internal();

  String? token;
  String? phpSessId;
  String? studentCode;
  String? password;
  bool isPreviousYear = false;

  String get numericCode => studentCode?.replaceAll(RegExp(r'[a-zA-Z]'), "") ?? '';

  String get baseUrl {
    if (isPreviousYear) {
      final String year = (DateTime.now().year - 2002).toString();
      return "https://web$year.spaggiari.eu/rest/v1/";
    }
    return "https://web.spaggiari.eu/rest/v1/";
  }

  Map<String, String> get loginHeaders => {
        'Content-Type': 'application/json',
        'Z-Dev-ApiKey': 'Tg1NWEwNGIgIC0K',
        'User-Agent': 'CVVS/std/4.1.3 Android/14',
      };

  Map<String, String> get authHeaders => {
        'Content-Type': 'application/json; charset=UTF-8',
        'Z-Dev-ApiKey': 'Tg1NWEwNGIgIC0K',
        'User-Agent': 'CVVS/std/4.1.3 Android/14',
        'Z-Auth-Token': token ?? '',
        'X-Requested-With': 'XMLHttpRequest'
      };

  void init(String code, String pass, bool previous) {
    studentCode = code;
    password = pass;
    isPreviousYear = previous;
  }

  Future<dynamic> doLogin() async {
    if (studentCode == null || password == null) return null;

    final response = await http.post(
      Uri.parse("${baseUrl}auth/login"),
      headers: loginHeaders,
      body: jsonEncode({
        "uid": studentCode,
        "pass": password,
        "ident": null,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      token = json['token'];
      return json;
    }
    return null;
  }

  Future<String> fetchPhpSessId() async {
    if (studentCode == null || password == null) {
      throw Exception('Credentials not set');
    }

    final uri = Uri.parse(
      'https://web.spaggiari.eu/auth-p7/app/default/AuthApi4.php?a=aLoginPwd',
    );

    final headers = <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      'Origin': 'https://web.spaggiari.eu',
      'User-Agent': 'Mozilla/5.0',
    };

    final body = 'cid=&uid=$studentCode&pwd=$password&pin=&target=';

    final resp = await http.post(uri, headers: headers, body: body);

    final setCookie = resp.headers['set-cookie'];
    if (setCookie == null || setCookie.isEmpty) {
      throw Exception('No Set-Cookie header present in the response');
    }

    final match = RegExp(r'PHPSESSID=([^;]+)').firstMatch(setCookie);
    if (match == null) {
      throw Exception('PHPSESSID not found');
    }

    phpSessId = match.group(1)!;
    return phpSessId!;
  }

  Future<http.Response> get(String endpoint, {Map<String, String>? headers}) {
    return http.get(Uri.parse("$baseUrl$endpoint"),
        headers: {...authHeaders, ...?headers});
  }

  Future<http.Response> post(String endpoint, {Map<String, String>? headers, Object? body}) {
    return http.post(Uri.parse("$baseUrl$endpoint"),
        headers: {...authHeaders, ...?headers}, body: body);
  }

  Future<http.Response> getExternal(String url, {Map<String, String>? headers}) {
    return http.get(Uri.parse(url), headers: headers);
  }

  Future<http.Response> postExternal(String url, {Map<String, String>? headers, Object? body}) {
    return http.post(Uri.parse(url), headers: headers, body: body);
  }
}
