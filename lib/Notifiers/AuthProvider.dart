import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DrawerUserName.dart';
import 'ProfilePictureProvider.dart';
import 'UserIdProvider.dart';

class MyAuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  MyAuthProvider() {
    // Load preferences when the provider is created
    _loadPreferences();
  }

  // Load preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isLoggedIn') ?? false;
    notifyListeners();
  }

  // Save authentication state to SharedPreferences
  Future<void> _saveAuthenticationState(bool authState) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', authState);
  }

  // Function to load authentication state from SharedPreferences
  Future<void> loadAuthenticationState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isLoggedIn') ?? false;
    notifyListeners();
  }

  void setAuthenticated(bool authState) {
    _isAuthenticated = authState;
    _saveAuthenticationState(authState); // Save the authentication state
    notifyListeners();
  }

  void signIn(BuildContext context) {
    Navigator.pop(context);


  }

  void signOut(BuildContext context) {
    // Implement your sign-out logic here
    // Example: set _isAuthenticated to false after successful sign-out
    _isAuthenticated = false;

    final userIdProvider = Provider.of<UserIdProvider>(context, listen: false);

    // Remove the saved username if the user logs out
    Provider.of<UserNameProvider>(context, listen: false).setUserName('');

    // Reset the profile picture to the default one
    Provider.of<ProfilePictureProvider>(context, listen: false).resetProfilePicture();

    // Set the _userId to null in the UserIdProvider
    userIdProvider.signOut();

    // Save the authentication state (user is now logged out)
    _saveAuthenticationState(false);

    notifyListeners();
  }
}
