import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/credentials.dart';

class Save {
  static final Save _instance = Save._internal();
  factory Save() => _instance;
  Save._internal();

  static const String _keyAccess = "access"; 
  static const String _keyAccounts = "accounts";
  static const String _keyCurrentCode = "current_account_code";
  static const String _keyFavoriteAchievements = "favorite_achievements";

  final ValueNotifier<List<String>> favoritesNotifier = ValueNotifier([]);

  Future<void> saveStringList(List<String> value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyAccess, value);
  }

  Future<Credentials?> getCredentials() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    final currentCode = prefs.getString(_keyCurrentCode);
    final accounts = await getAllAccounts();

    if (currentCode != null && currentCode.isNotEmpty && accounts.isNotEmpty) {
      try {
        return accounts.firstWhere((a) => a.code == currentCode);
      } catch (_) {}
    }

    final List<String>? value = prefs.getStringList(_keyAccess);
    if (value != null && value.length >= 2) {
      return Credentials.fromList(value);
    }

    if (accounts.isNotEmpty) return accounts.first;

    return null;
  }

  Future<List<Credentials>> getAllAccounts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_keyAccounts);
    if (jsonList == null) return [];

    return jsonList
        .map((s) => Credentials.fromJson(jsonDecode(s)))
        .toList();
  }

  Future<void> addAccount(Credentials credentials) async {
    final accounts = await getAllAccounts();
    // Remove if already exists to avoid duplicates (based on code)
    accounts.removeWhere((a) => a.code == credentials.code);
    accounts.add(credentials);
    
    await _saveAccounts(accounts);
    await setCurrentAccount(credentials.code);
  }

  Future<void> removeAccount(String code) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final accounts = await getAllAccounts();
    accounts.removeWhere((a) => a.code == code);
    await _saveAccounts(accounts);
    
    if (prefs.getString(_keyCurrentCode) == code) {
      await prefs.remove(_keyCurrentCode);
    }
    
    // Always clear legacy access when removing an account to be safe
    await prefs.remove(_keyAccess);
  }

  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final currentCode = prefs.getString(_keyCurrentCode);
    if (currentCode != null) {
      await removeAccount(currentCode);
    }
    await prefs.remove(_keyCurrentCode);
    await prefs.remove(_keyAccess);
    // If no more accounts, we are fully logged out
  }

  Future<void> setCurrentAccount(String code) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (code.isEmpty) {
      await prefs.remove(_keyCurrentCode);
    } else {
      await prefs.setString(_keyCurrentCode, code);
    }
  }

  Future<void> _saveAccounts(List<Credentials> accounts) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final jsonList = accounts.map((a) => jsonEncode(a.toJson())).toList();
    await prefs.setStringList(_keyAccounts, jsonList);
  }

  // --- Favorite Achievements ---
  
  Future<List<String>> getFavoriteAchievements() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList(_keyFavoriteAchievements) ?? [];
    favoritesNotifier.value = favs;
    return favs;
  }

  Future<void> toggleFavoriteAchievement(String title) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(_keyFavoriteAchievements) ?? [];
    
    if (favorites.contains(title)) {
      favorites.remove(title);
    } else {
      if (favorites.length < 3) {
        favorites.add(title);
      }
    }
    
    await prefs.setStringList(_keyFavoriteAchievements, favorites);
    favoritesNotifier.value = List.from(favorites);
  }

  Future<bool> isFavoriteAchievement(String title) async {
    final favorites = await getFavoriteAchievements();
    return favorites.contains(title);
  }
}
