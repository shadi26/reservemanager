import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserIdProvider with ChangeNotifier {
  String? _userId;

  String? get userId => _userId;

  Future<void> setUserId(String userId) async {
    _userId = userId;
    // Save the userId to SharedPreferences
    await saveUserIdToPreferences(userId);
    notifyListeners();
  }

  void signOut() {
    _userId = null;
    // Clear the userId from SharedPreferences on sign out
    clearUserIdFromPreferences();
    notifyListeners();
  }

  Future<String?> getUserId() async {
    // If userId is not already loaded, try to load it from SharedPreferences
    if (_userId == null) {
      _userId = await loadUserIdFromPreferences();
    }
    return _userId;
  }

  // Save the userId to SharedPreferences
  Future<void> saveUserIdToPreferences(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  // Load the userId from SharedPreferences
  Future<String?> loadUserIdFromPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // Clear the userId from SharedPreferences
  Future<void> clearUserIdFromPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }
}
