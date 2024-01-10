import '../services/database.dart';
class LanguageMaps {
  static Map<String, dynamic> englishLan = {};
  static Map<String, dynamic> arabicLan = {};
  static Map<String, dynamic> hebrewLan = {};

  static Future<void> loadDataForLanguages() async {
    englishLan = await fetchDataFromFirebaseForlanguage('english');
    arabicLan = await fetchDataFromFirebaseForlanguage('arabic');
    hebrewLan = await fetchDataFromFirebaseForlanguage('herbew');

  }
}