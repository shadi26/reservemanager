import 'package:flutter/cupertino.dart';

class LocationSelectionNotifier extends ChangeNotifier {
  bool _hasSelectedLocation = false;
  late String _selectedLocation; // Add a variable to store the location
  late List<dynamic> _imageUrls;

  List<dynamic> get imageUrls => _imageUrls;

  bool get hasSelectedLocation => _hasSelectedLocation;
  String get selectedLocation => _selectedLocation; // Getter for the location



  // Updated method to accept a location parameter
  void selectLocation(String location,List<dynamic> imageUrls) {
    _hasSelectedLocation = true;
    _selectedLocation = location; // Store the location
    _imageUrls = imageUrls;
    notifyListeners();
  }
}