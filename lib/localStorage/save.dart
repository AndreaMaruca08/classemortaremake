import 'package:shared_preferences/shared_preferences.dart';

import '../auth/credentials.dart';

class Save{
  Future<void> saveStringList(List<String> value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("access", value);
  }
  Future<Credentials?>? getCredentials() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? value = prefs.getStringList("access");
    if(value == null) {
      return null;
    }
    return Credentials.fromList(value);
  }
}