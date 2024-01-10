import 'package:flutter/material.dart';

class PaymentMethodNotifier with ChangeNotifier {
  String _selectedPaymentMethod = '';

  String get selectedPaymentMethod => _selectedPaymentMethod;

  set selectedPaymentMethod(String value) {
    _selectedPaymentMethod = value;
    notifyListeners();
  }
}