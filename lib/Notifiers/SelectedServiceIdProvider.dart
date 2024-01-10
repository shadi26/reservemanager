import 'package:flutter/material.dart';

class SelectedServiceIdProvider with ChangeNotifier {
  String? _selectedServiceId;

  String? get selectedServiceId => _selectedServiceId;

  void setSelectedServiceId(String serviceId) {
    _selectedServiceId = serviceId;
    notifyListeners();
  }
}