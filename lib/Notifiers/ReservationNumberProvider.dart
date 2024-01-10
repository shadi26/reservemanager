import 'package:flutter/material.dart';

class ReservationNumberProvider with ChangeNotifier {
  int _ReservationNumberCounter = 0;

  int get ReservationNumberCounter => _ReservationNumberCounter;

  void incrementCounter() {
    _ReservationNumberCounter++;
    notifyListeners();
  }
}