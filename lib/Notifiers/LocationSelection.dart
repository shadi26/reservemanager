import 'package:flutter/cupertino.dart';

class LocationSelectionNotifier extends ChangeNotifier {
  bool _hasSelectedLocation = false;
  late String _selectedLocation; // Add a variable to store the location
  late List<dynamic> _imageUrls = ['https://firebasestorage.googleapis.com/v0/b/reserve-cd385.appspot.com/o/images%2F1.jpg?alt=media&token=0ca1ee8a-029c-4ec0-9af4-d755d4ac8619',
  'https://firebasestorage.googleapis.com/v0/b/reserve-cd385.appspot.com/o/images%2F2.jpg?alt=media&token=747982d1-3ba6-4222-b57a-ab19cae4d0a8',
  'https://firebasestorage.googleapis.com/v0/b/reserve-cd385.appspot.com/o/images%2F19.jpg?alt=media&token=7237076d-3468-482e-af82-28e55088fb77'];

  List<dynamic> get imageUrls => _imageUrls;

  bool get hasSelectedLocation => _hasSelectedLocation;
  String get selectedLocation => _selectedLocation='shefaamr'; // Getter for the location



  // Updated method to accept a location parameter
  void selectLocation(String location,List<dynamic> imageUrls) {
    _hasSelectedLocation = true;
    _selectedLocation = location; // Store the location
    _imageUrls = imageUrls;
    notifyListeners();
  }
}