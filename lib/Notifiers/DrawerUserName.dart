import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserNameProvider with ChangeNotifier {
  String _userName = '';

  String get userName => _userName;

  Future<void> setUserName(String newUserName) async {
    _userName = newUserName;
    notifyListeners(); // Notify all the listeners about the change

    // Save the userName to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userName', newUserName);
  }

  Future<void> loadUserNameFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUserName = prefs.getString('userName');
    if (savedUserName != null) {
      _userName = savedUserName;
      notifyListeners(); // Notify listeners after loading from SharedPreferences
    }
  }
}
