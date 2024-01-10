import 'package:flutter/foundation.dart';

class CheckoutProvider with ChangeNotifier {
  bool _isButtonPressed = false;

  bool get isButtonPressed => _isButtonPressed;

  void setButtonPressed(bool value) {
    _isButtonPressed = value;
    notifyListeners();
  }
}