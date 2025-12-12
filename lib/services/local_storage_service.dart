// lib/services/local_storage_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class LocalStorageService {
  static const String _notesKey = 'notes';
  static const String _darkModeKey = 'dark_mode';

  // Simpan semua catatan ke SharedPreferences
  static Future<void> saveNotes(List<Note> notes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = notes.map((note) => note.toMap()).toList();
      await prefs.setString(_notesKey, jsonEncode(jsonList));
    } catch (e) {
      print('Error saving notes: $e');
    }
  }

  // Load semua catatan dari SharedPreferences
  static Future<List<Note>> loadNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_notesKey);

      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => Note.fromMap(json)).toList();
    } catch (e) {
      print('Error loading notes: $e');
      return [];
    }
  }

  // Simpan status dark mode
  static Future<void> saveDarkMode(bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, isDark);
    } catch (e) {
      print('Error saving dark mode: $e');
    }
  }

  // Load status dark mode
  static Future<bool> loadDarkMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_darkModeKey) ?? false;
    } catch (e) {
      print('Error loading dark mode: $e');
      return false;
    }
  }
}