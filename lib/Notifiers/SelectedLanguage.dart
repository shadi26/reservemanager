import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart'; // Import the intl package
import 'package:shared_preferences/shared_preferences.dart';
import '../language/language.dart';
import '../language/language_constants.dart';
import '../services/languagesMap.dart';

class SelectedLanguage with ChangeNotifier {
  String _selectedLanguage = 'English';
  String _profileSelectedLanguage = 'العربية';
  Map<String, dynamic>? _translations;

  String get selectedLanguage => _selectedLanguage;

  String get profileSelectedLanguage => _profileSelectedLanguage;

  SelectedLanguage() {
    loadTranslations();
  }

  void setProfileLanguage(String language) {
    _profileSelectedLanguage = language;
    _selectedLanguage = language;
    loadTranslations();
    notifyListeners();
  }

  void setLanguage(String language) {
    _selectedLanguage = language;
    loadTranslations();
    notifyListeners();
  }

  Future<void> loadDefaultLanguageFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('defaultLanguage') != null) {
      String? savedDefaultLanguage = prefs.getString('defaultLanguage');
      String languageCode;

      if (savedDefaultLanguage!.toLowerCase() == "english") {
        languageCode = 'en';
      } else if (savedDefaultLanguage.toLowerCase() == "עברית") {
        languageCode = 'he';
      } else {
        languageCode = 'ar';
      }

      Locale locale = await setLocale(languageCode);
      Get.updateLocale(locale);
      setLanguage(savedDefaultLanguage!);

      loadTranslations();
      notifyListeners();
    }
  }

  Future<void> loadTranslations() async {
    if (_selectedLanguage.toLowerCase() == "english") {
      _translations = LanguageMaps.englishLan;
    } else if (_selectedLanguage.toLowerCase() == "עברית") {
      _translations = LanguageMaps.hebrewLan;
    } else {
      _translations = LanguageMaps.arabicLan;
    }
  }

  String translate(String key) {
    // Use the Intl package to handle translations
    String translation = _translations?[key] ?? key;
    return Intl.message(translation, name: key, locale: _selectedLanguage);
  }

  String untranslate(String value) {
    // Reverse lookup the key based on the value
    MapEntry<String, dynamic>? entry = _translations?.entries.firstWhere(
      (entry) => entry.value == value,
      orElse: () => MapEntry("", null),
    );
    return entry?.key ?? value;
  }
}
