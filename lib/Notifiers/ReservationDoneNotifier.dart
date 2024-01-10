import 'package:flutter/material.dart';

class ReservationDoneNotifier extends ChangeNotifier {
  int _reservationsDone = 0;

  int get reservationsDone => _reservationsDone;

  void notifyReservationDone() {
    _reservationsDone++;
    notifyListeners();
  }
}