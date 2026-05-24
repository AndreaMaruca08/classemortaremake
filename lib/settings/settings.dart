import 'package:shared_preferences/shared_preferences.dart';

class Settings{
  int msAnimation;
  int graphicAnimation;
  int columnGraphicAnimation;
  Settings({
    required this.msAnimation,
    required this.graphicAnimation,
    required this.columnGraphicAnimation,
  });

  Future<void> salvaImpostazioni() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('msAnimation', msAnimation);
    await prefs.setInt('graphicAnimation', graphicAnimation);
    await prefs.setInt('columnGraphicAnimation', columnGraphicAnimation);
  }

  Future<void> caricaImpostazioni() async {
    final prefs = await SharedPreferences.getInstance();
    msAnimation = prefs.getInt('msAnimazioneVoto') ?? 1500;
    graphicAnimation = prefs.getInt('AnimazioneGraficoAndamento') ?? 1500;
    columnGraphicAnimation = prefs.getInt('AnimazioneGraficoNumeri') ?? 1200;
  }
}