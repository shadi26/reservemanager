import 'package:flutter/foundation.dart';

class CurrentPageProvider with ChangeNotifier {
  String _currentPage = "";

  String get currentPage => _currentPage;

  void setCurrentPage(String pageName) {
    _currentPage = pageName;
    notifyListeners();
  }
}