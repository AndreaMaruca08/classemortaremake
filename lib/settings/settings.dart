import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  int gradeAnimationMs;
  int trendChartAnimationMs;
  int numbersChartAnimationMs;

  Settings({
    required this.gradeAnimationMs,
    required this.trendChartAnimationMs,
    required this.numbersChartAnimationMs,
  });

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('msAnimazioneVoto', gradeAnimationMs);
    await prefs.setInt(
        'AnimazioneGraficoAndamento', trendChartAnimationMs);
    await prefs.setInt('AnimazioneGraficoNumeri', numbersChartAnimationMs);
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    gradeAnimationMs = prefs.getInt('msAnimazioneVoto') ?? 1500;
    trendChartAnimationMs =
        prefs.getInt('AnimazioneGraficoAndamento') ?? 1500;
    numbersChartAnimationMs = prefs.getInt('AnimazioneGraficoNumeri') ?? 1200;
  }
}
