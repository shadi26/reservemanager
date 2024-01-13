import 'package:flutter/material.dart';

class ReservationStatusChangedNotifier extends ChangeNotifier {
  void notifyReservationStatusChanged() {
    notifyListeners();
  }
}