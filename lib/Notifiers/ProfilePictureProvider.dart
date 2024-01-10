import 'package:flutter/material.dart';

class ProfilePictureProvider with ChangeNotifier {
  String _profilePicture = 'https://example.com/profile_picture.jpg';

  String get profilePicture => _profilePicture;

  void setProfilePicture(String newProfilePicture) {
    _profilePicture = newProfilePicture;
    notifyListeners();
  }

  void resetProfilePicture() {
    _profilePicture = 'https://example.com/profile_picture.jpg';
    notifyListeners();
  }
}