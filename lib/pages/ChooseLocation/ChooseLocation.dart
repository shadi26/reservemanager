import 'dart:async';

import 'package:geocoding/geocoding.dart';
import '../../CustomWidgets/CustomDrawer.dart';
import '../../Notifiers/DrawerUserName.dart';
import '../../Notifiers/LocationSelection.dart';
import '../../Notifiers/SelectedLanguage.dart';
import '../../uistates/LoadingScreenWidget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'choose_location_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reserve/CustomWidgets/ShimmerLoading.dart';
import 'map_style.dart'; // Import the file where you store the map style JSON
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../../Notifiers/AuthProvider.dart';
// Clear existing data and add the default 'Select a Location'

late double lat;
late double long;
int selectedCarId = 0;
List<Map<String, dynamic>> citiesWithLatLng = [];

Map<String, dynamic> cityInfo = {'id': 0, 'name': 'null', 'latLng': null};
final Map<String, String> citiesNameMapping = {
  "Shefa-'Amr": "shefaamr",
  "Shefar'am": "shefaamr",
  "Tamra" : "tamra",
  // Add more city names as needed
};

Map<String, dynamic> getCityInfoByArabicName(String arabicName) {
  try {
    return citiesWithLatLng.firstWhere(
      (city) => city['name'] == arabicName,
      orElse: () => cityInfo, // Return the default value
    );
  } catch (e) {
    print(e);
    return cityInfo; // Return the default value in case of an error
  }
}

Future<Position> _liveLocation() async {
  LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  try {
    Position position =
        await Geolocator.getPositionStream(locationSettings: locationSettings)
            .first;

    return position;
  } catch (e) {
    print("Error getting location: $e");
    // Handle errors, e.g., show an alert to the user
    throw e; // rethrow the exception if needed
  }
}

class ChooseLocationWidget extends StatefulWidget {
  const ChooseLocationWidget({Key? key}) : super(key: key);

  @override
  _ChooseLocationWidgetState createState() => _ChooseLocationWidgetState();
}

class _ChooseLocationWidgetState extends State<ChooseLocationWidget> {
  late bool _isLoading;
  late ChooseLocationModel _model;
  List<maps.Marker> markers = []; //for markers in the map
  GoogleMapController? _mapController; //help moving to the marker
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late String cityName;
  late  List<dynamic> imageUrls;
  Completer<void> _dataFetchCompleter = Completer<void>(); // Completer to handle asynchronous data fetching


  void _setupMarkers() {
    final selectedLanguage = Provider.of<SelectedLanguage>(context, listen: false);

    //set up the markers on the map

    for (var city in citiesWithLatLng) {
      if (city['latLng'] != null) {
        markers.add(
          maps.Marker(
            markerId: maps.MarkerId(city['name']),
            position: city['latLng'],
            infoWindow: maps.InfoWindow(title: selectedLanguage.translate(city['name'])),
          ),
        );
      }
    }
  }

  Future<void> _getCurrentLocationAndRedirect() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showLocationServiceDialog();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Handle denied permission
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Handle permanently denied permission
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      double lat = position.latitude;
      double long = position.longitude;

      // Use geocoding to get the city name
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);

      if (placemarks.isNotEmpty) {

        //getting the cityname and mapping it
        String cityName = placemarks[0].locality ?? 'Unknown';

        cityName=citiesNameMapping[cityName]!;



        for (var city in citiesWithLatLng) {
          if (city['name'] == cityName) {
            // Match found, retrieve imageUrls
            imageUrls = city['imageUrls'];
            break; // Break out of the loop once you find the matching city
          }
        }

        Provider.of<LocationSelectionNotifier>(
            context,
            listen: false)
            .selectLocation(
            cityName, imageUrls);

        // Now you can use the cityName as needed
      } else {
        print('No placemarks found');
      }

    } catch (e) {
      print("Error getting location: $e");
      // Handle error getting location
    }
  }

  Future<void> _fetchDataFromFirebase() async {
    try {
      // Clear existing data
      citiesWithLatLng.clear();
      citiesWithLatLng.add({
        'id': 0,
        'name': 'Select a Location',
        'latLng': null,
        'imageUrls': []
      });
      // read from the database
      final QuerySnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('cities').get();

      // Add data from Firebase
      snapshot.docs.forEach((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
        final Map<String, dynamic> cityData = doc.data()!;
        citiesWithLatLng.add({
          'id': cityData['id'],
          'name': cityData['name'],
          'latLng': cityData['latLng'] != null
              ? maps.LatLng(
            cityData['latLng']['latitude'],
            cityData['latLng']['longitude'],
          )
              : null,
          'imageUrls': cityData['imageUrls'],
        });

      });

      _setupMarkers(); // Update markers as well if needed
     // _dataFetchCompleter.complete(); // Complete the Future when data is fetched
    } catch (e) {
      print("Error fetching data: $e");
      if (!_dataFetchCompleter.isCompleted) {
        _dataFetchCompleter.completeError(e); // Complete with an error if there's an issue
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _isLoading = true;
    _model = createModel(context, () => ChooseLocationModel());


    // Start fetching data
    _fetchDataFromFirebase().then((_) {
      _dataFetchCompleter.complete(); // Complete the Future when data is fetched
    }).catchError((error) {
      _dataFetchCompleter.completeError(error); // Complete with an error if there's an issue
    });


    WidgetsBinding.instance!.addPostFrameCallback((_) {
    Provider.of<SelectedLanguage>(context, listen: false).loadDefaultLanguageFromPreferences();
    });



    super.initState();
  }
  void _moveToMarker(Map<String, dynamic> city) {
    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLng(city['latLng']));
    }
  }
  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }
  void showLocationServiceDialog() {
    final selectedLanguage = Provider.of<SelectedLanguage>(context, listen: false);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Section with Icon
            Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Color(0xFFD54D57), // Red color
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 25.0,
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    selectedLanguage.translate("activatelocationtitle"),
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Amiri',
                      fontSize: 20.0,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Section with Text and Buttons
            Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/locationdialogImg.png', // Replace with the path to your image
                    width: 200.0, // Set the desired width
                    height: 200.0, // Set the desired height
                    fit: BoxFit.contain, // Adjust the fit as needed
                  ),
                  Text(
                    selectedLanguage.translate("activatelocationmsg"),
                    style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 20.0
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(Get.overlayContext!).pop(); // Close the current dialog
                      Geolocator.openLocationSettings();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFFD54D57), // Background color

                    ),
                    child: Text(
                      selectedLanguage.translate("activatelocationbutton"),
                      style: TextStyle(
                        color: Colors.white, // Text color
                        fontFamily: 'Amiri',
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: FutureBuilder<void>(
        future: _dataFetchCompleter.future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display shimmer loading during the loading state
            _isLoading = true;
            return LoadingScreen();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            Future.delayed(Duration(seconds: 2), () {
              // Delay for 1 second before setting _isLoading = false
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            });

            return _BuildTree(context, _isLoading);
          }
        },
      ),
    );

  }
Widget _BuildTree(BuildContext context , bool loading)
{
  // Get the current username from UserNameProvider
  String currentUserName = Provider.of<UserNameProvider>(context).userName;
  // Get the selected language from the provider
  final selectedLanguage = Provider.of<SelectedLanguage>(context);

  if (isiOS) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarBrightness: Theme.of(context).brightness,
        systemStatusBarContrastEnforced: true,
      ),
    );
  }
  context.watch<FFAppState>();
  final authProvider = context.watch<MyAuthProvider>();
  return GestureDetector(
    onTap: () => _model.unfocusNode.canRequestFocus
        ? FocusScope.of(context).requestFocus(_model.unfocusNode)
        : FocusScope.of(context).unfocus(),
    child: Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xFFD54D57),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: Colors.white,
            size: 24.0,
          ),
          onPressed: () {
            scaffoldKey.currentState!.openDrawer();
          },
        ),
        flexibleSpace: Container(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.asset(
              'assets/icons/ReserveLogo.png',
              width: 400.0, // Increase the width value
              height: 100.0, // Increase the height value
              fit: BoxFit.contain,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 16.0, 0.0),
            // Add right padding
            child: InkWell(
              onTap: () async {
                _getCurrentLocationAndRedirect();
              },
              child: Image.asset(
                'assets/icons/location.png', // Replace with the correct path
                width: 40.0,
                height: 40.0,
              ),
            ),
          ),
        ],
        centerTitle: true,
        elevation: 20,
        shadowColor: Color(0xFFD54D57),
      ),
      drawer: CustomDrawer(
        isAuthenticated: authProvider.isAuthenticated,
      ),
      body: Stack(
        children: [
          LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: maps.LatLng(31.759401948205593, 34.82159093234923),
                    // Here's the LatLng
                    zoom: 9.0,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller; //passing controller
                    controller.setMapStyle(
                        mapStyleJson); //set the jason for google maps
                  },
                  markers: Set.from(markers),
                );
              }),

          DraggableScrollableSheet(
              initialChildSize: 0.3,
              minChildSize: 0.07,
              maxChildSize: 0.6,
              snapSizes: [0.07, 0.6],
              snap: true,
              builder: (BuildContext context, scrollSheetController) {
                return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.0),
                        topRight: Radius.circular(12.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          // Set the desired shadow color
                          spreadRadius: 2,
                          // Adjust the spread radius for width
                          blurRadius: 10,
                          // Adjust the blur radius for intensity
                          offset: Offset(0,
                              2), // Adjust the offset to control the position
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      physics: ClampingScrollPhysics(),
                      controller: scrollSheetController,
                      itemCount: citiesWithLatLng.length,
                      itemBuilder: (BuildContext context, int index) {
                        final city = citiesWithLatLng[index];
                        if (index == 0) {
                          return Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: 80,
                                    child: Container(
                                      height: 5,
                                      // Set the desired height of your Divider
                                      decoration: BoxDecoration(
                                        color: Color(0xFFD54D57),
                                        borderRadius: BorderRadius.circular(
                                            5), // Set the desired radius
                                      ),
                                    ),
                                  ),
                                  _isLoading
                                      ?ShimmerLoading.textShimmer(context)
                                      :Text(
                                    //'اختر المدينة',
                                    selectedLanguage.translate('pickingcity'),
                                    style: TextStyle(
                                      fontFamily: 'Amiri',
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,  // or FontWeight.bold for bold
                                    ),
                                  )
                                ],
                              ));
                        }
                        return Column(
                          children: [

                            Card(
                              margin: EdgeInsets.all(4.0),
                              elevation: 1,
                              color: Colors.white,
                              child: _isLoading
                                  ? ShimmerLoading.shimmerLoadingTitles(
                                  context) // Show shimmer loading if _isLoading is true
                                  : ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.all(7),
                                onTap: () {
                                  cityName = city['name'];
                                  imageUrls = city['imageUrls'];

                                  setState(() {
                                    _moveToMarker(city);
                                    selectedCarId = city['id'];
                                  });


                                  Future.delayed(
                                      Duration(milliseconds: 300), () {
                                    Provider.of<LocationSelectionNotifier>(
                                        context,
                                        listen: false)
                                        .selectLocation(
                                        cityName, imageUrls);
                                  });
                                },
                                leading: Icon(
                                  Icons.location_pin,
                                  color: selectedCarId == city['id']
                                      ? Color(0xFFD54D57)

                                      : Color(0xFFEA4437),
                                ),
                                title: Text(
                                  // Translate the city name
                                  selectedLanguage
                                      .translate(city['name']),
                                  style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                    color: selectedCarId == city['id']
                                        ? Color(0xFFD54D57)
                                        .withOpacity(0.9)
                                        : Colors.black.withOpacity(0.7),
                                  ),
                                ),
                                selected: selectedCarId == city['id'],
                              ),
                            ),
                          ],
                        );
                      },
                    ));
              }),
          // Here you can add other widgets that will be displayed over the map
        ],
      ),
    ),
  );
}
}
