import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  int gradeAnimationMs;
  int trendChartAnimationMs;
  int numbersChartAnimationMs;
  ThemeMode themeMode;

  Settings({
    this.gradeAnimationMs = 1500,
    this.trendChartAnimationMs = 1500,
    this.numbersChartAnimationMs = 1200,
    this.themeMode = ThemeMode.system,
  });

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('msAnimazioneVoto', gradeAnimationMs);
    await prefs.setInt('AnimazioneGraficoAndamento', trendChartAnimationMs);
    await prefs.setInt('AnimazioneGraficoNumeri', numbersChartAnimationMs);
    await prefs.setInt('themeMode', themeMode.index);
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    gradeAnimationMs = prefs.getInt('msAnimazioneVoto') ?? 1500;
    trendChartAnimationMs = prefs.getInt('AnimazioneGraficoAndamento') ?? 1500;
    numbersChartAnimationMs = prefs.getInt('AnimazioneGraficoNumeri') ?? 1200;
    final themeIndex = prefs.getInt('themeMode') ?? ThemeMode.system.index;
    themeMode = ThemeMode.values[themeIndex];
  }
}
