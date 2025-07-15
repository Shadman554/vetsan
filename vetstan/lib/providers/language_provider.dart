import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  Locale _currentLocale = const Locale('en');
  Map<String, dynamic> _translations = {};

  Locale get currentLocale => _currentLocale;
  
  // Constructor now initializes with default values and loads saved language in background
  LanguageProvider() {
    // Start with English translations by default
    loadTranslations('en').then((_) {
      // After loading default English translations, check for saved language preference
      _loadSavedLanguage();
    });
  }

  Future<void> _loadSavedLanguage() async {
    try {
      // Use the pre-initialized SharedPreferences instance from main.dart when possible
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey);
      if (savedLanguage != null && savedLanguage != 'en') {
        // Only load different language if it's not English (which we already loaded)
        await setLanguage(savedLanguage);
      }
    } catch (e) {
      // Error already handled by loading English translations in constructor
      debugPrint('Error loading saved language: $e');
    }
  }

  // Optimized language setting
  Future<void> setLanguage(String languageCode) async {
    try {
      // Load translations first (this will also update locale and notify listeners)
      await loadTranslations(languageCode);
      
      // Save preference in background without awaiting
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString(_languageKey, languageCode);
      });
    } catch (e) {
      debugPrint('Error setting language: $e');
      // If there's an error setting the new language, try to fall back to English
      if (languageCode != 'en') {
        await loadTranslations('en');
      }
    }
  }

  // Optimized translation loading
  Future<void> loadTranslations(String languageCode) async {
    try {
      // Load translations asynchronously
      final jsonString = await rootBundle.loadString('assets/translations/$languageCode.json');
      _translations = json.decode(jsonString);
      // Update locale after translations are loaded
      _currentLocale = Locale(languageCode);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading translations: $e');
      // If translations can't be loaded, use an empty map but don't change locale
      _translations = {};
    }
  }

  String translate(String key) {
    return _translations[key] ?? key;
  }
}
