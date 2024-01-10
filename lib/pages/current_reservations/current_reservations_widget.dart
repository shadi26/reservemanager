import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:reserve/CustomWidgets/ShimmerLoading.dart';
import '../../CustomWidgets/CustomDrawer.dart';
import '../../Notifiers/AuthProvider.dart';
import '../../Notifiers/ReservationDoneNotifier.dart';
import '../../Notifiers/UserIdProvider.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '../../CustomWidgets/CustomResCard.dart';
import '../../Notifiers/SelectedLanguage.dart';

List<Map<String, dynamic>> reservationData = [];

class CurrentReservationsWidget extends StatefulWidget {
  const CurrentReservationsWidget({Key? key}) : super(key: key);

  @override
  _CurrentReservationsWidgetState createState() =>
      _CurrentReservationsWidgetState();
}

class _CurrentReservationsWidgetState extends State<CurrentReservationsWidget>
    with TickerProviderStateMixin {
  late TabController _tabController; // Initialize TabController here
  List<Map<String, dynamic>> reservations = [];
  final unfocusNode = FocusNode();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Key _currentKey = UniqueKey(); // Add a unique key for TabBarView
  List<Map<String, dynamic>> data = [];
  bool _isDataLoaded = false;


  Map<String, dynamic> mapFirebaseDataToLocal(Map<String, dynamic> firebaseData) {
    /************************************************************* calculating the 30 minutes difference *************************************************/
    // Get the current time
    Timestamp currentTime = Timestamp.now();

    // Get the reservation timestamp from the document
    Timestamp reservationTimeStamp = firebaseData['timestamp'];

    // Calculate the difference in seconds between the current time and the reservation timestamp
    int timeDiff= currentTime.seconds - reservationTimeStamp.seconds;

    // Subtract 30 minutes (1800 seconds) from the calculated difference
    int remainingTime = (1800 - timeDiff).abs();

    // Ensure the remaining time is between 0 and 1800 seconds
    remainingTime = remainingTime.clamp(0, 1800);
    //calculating the 30 minutes difference
    // Extract relevant data
    String reservationDate = firebaseData['date'];
    String reservationTime = firebaseData['time'];
    String formattedTimeStamp = DateFormat('dd-MM-yyyy HH:mm').format(firebaseData['timestamp'].toDate());



    // Combine date and time to create a DateTime object
    String formattedDateString = '$reservationDate $reservationTime';
    DateTime reservationDateTime = DateTime.parse(
      formattedDateString.replaceAllMapped(
        RegExp(r'(\d{2})-(\d{2})-(\d{4}) (\d{2}:\d{2})'),
            (match) => '${match[3]}-${match[2]}-${match[1]} ${match[4]}',
      ),
    );

    // Get the current time
    DateTime now = DateTime.now();

    // Calculate the time difference
    Duration timeDifference = reservationDateTime.difference(now);

    // Get reservation type based on the time difference
    String reservationType =
    reservationDateTime.isBefore(now) ? 'old' : 'current';

    // Generate a random reservation number
    int randomReservationNumber = Random().nextInt(10000) + 1;
    return {
      'rid': firebaseData['documentId'], // Use 'documentId' to represent Firestore document ID
      'reservationTime': formattedTimeStamp ?? '',
      'reservationNumber': '$randomReservationNumber',
      'venueName': firebaseData['title'] ?? '',
      'paymentType': firebaseData['paymentMethod'] ?? '',
      'imageUrl': firebaseData['image'] ?? '',
      'reservationType': reservationType,
      'reservationResult': firebaseData['status'],
      'reservationTimeRemaining': timeDiff,
      'reservationDuration': timeDifference,
      'timeBooked' : '${firebaseData['date']} ${firebaseData['time']}' ?? '' ,
      'totalAmount' : firebaseData['totalamount'],
      'reservationTimeStamp' : firebaseData['timestamp'],
      'formattedDateString' : formattedDateString,
    };
  }


  Future<Map<String, dynamic>> fetchServiceData(String sid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> serviceSnapshot =
          await FirebaseFirestore.instance
              .collection(
                  'servicesInACity') // Update with your actual collection name
              .doc(sid)
              .get();

      return serviceSnapshot.data() ?? {};
    } catch (error) {
      print('Error fetching service data: $error');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> _fetchDataWithJoin(
      String collectionName,
      String userId,
      ) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference<Map<String, dynamic>> collection =
      firestore.collection(collectionName);

      // Fetch documents with 'uid' equal to userId
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await collection.where('uid', isEqualTo: userId).get();

      // Extract the list of 'sid' values and document IDs from the documents
      List<Map<String, dynamic>> data = querySnapshot.docs.map((doc) {
        return {
          'documentId': doc.id,
          'data': doc.data(),
        };
      }).toList();

      // Fetch all service data in a single query using Future.wait
      List<Future<Map<String, dynamic>>> serviceDataFutures = data
          .map((entry) => fetchServiceData(entry['data']['sid']))
          .toList();
      List<Map<String, dynamic>> serviceDataList = await Future.wait(serviceDataFutures);

      // Merge reservationData with serviceData
      List<Map<String, dynamic>> mergedData = List.generate(
        data.length,
            (index) {
          Map<String, dynamic> reservationData = data[index]['data'];
          Map<String, dynamic> serviceData = serviceDataList[index];
          return {
            'documentId': data[index]['documentId'],
            ...reservationData,
            ...serviceData,
          };
        },
      );

      return mergedData;
    } catch (e) {
      // Handle errors if necessary
      print('Error fetching data: $e');
      return [];
    }
  }



  Future<List<Map<String, dynamic>>> fetchDataWithJoin(String userId) async {
    try {
      // Create a stopwatch instance for the entire function
      Stopwatch stopwatch = Stopwatch()..start();

      //taking 4.5 secs only for this function needs to be fixed
      List<Map<String, dynamic>> data = await _fetchDataWithJoin("Reservations", userId);

      // Stop the stopwatch for the entire function
      stopwatch.stop();
      // Create a stopwatch instance for the mapping process
      Stopwatch mappingStopwatch = Stopwatch()..start();

      // Map each item in data using mapFirebaseDataToLocal
      List<Map<String, dynamic>> mappedData = data
          .map((reservation) => mapFirebaseDataToLocal(reservation))
          .toList();

      // Stop the stopwatch for the mapping process
      mappingStopwatch.stop();

      //change the state of is dataloaded for the future builder
      _isDataLoaded = true;

      return mappedData;
    } catch (e) {
      // Handle errors if necessary
      print('Error fetching data: $e');
      return []; // Return an empty list in case of an error
    }
  }



  Future<String?> getUserId(BuildContext context) async {
    return Provider.of<UserIdProvider>(context).userId;
  }


  @override
  void initState() {
    super.initState();

    // Initialize TabController
    _tabController = TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    );

    // Add a listener to the TabController
    _tabController.addListener(() {
      // Trigger actions when the tab changes
      _tabController.animateTo(_tabController.index);
      //rebuildTabView();
    });
  }

  @override
  void dispose() {
    // Dispose of the TabController
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getUserId(context).then((userId) {
      if (userId != null) {
        fetchDataWithJoin(userId).then((value) {
          //rebuildTabView(); // Force a rebuild
        });
      } else {
        // Handle the case where userId is null
        print('User ID is null.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //Notifier to rebuild the page when new reservation done
    final reservationNotifier = Provider.of<ReservationDoneNotifier>(context);
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
      onTap: () => unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.grey[100],
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
          centerTitle: true,
          elevation: 4.0,
        ),
        drawer: CustomDrawer(
          isAuthenticated: authProvider.isAuthenticated,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment(0.0, 0),
                      child: TabBar(
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey,
                        labelStyle: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 18.0,
                          // Set your desired font size
                          fontWeight: FontWeight.bold,
                          // Set your desired font weight
                          color: Colors.black, // Set your desired text color
                        ),
                        unselectedLabelStyle: TextStyle(
                          fontFamily: 'Amiri',
                        ),
                        indicatorColor: Color(0xFFD54D57),
                        padding:
                            EdgeInsetsDirectional.fromSTEB(4.0, 4.0, 4.0, 4.0),
                        tabs: [
                          Tab(
                            text: selectedLanguage
                                .translate('currentreservation'),
                          ),
                          Tab(
                            text: selectedLanguage
                                .translate('previousreservation'),
                          ),
                        ],
                        controller: _tabController,
                      ),
                    ),
                    Expanded(
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: getUserId(context).then((userId) => fetchDataWithJoin(userId ?? '')),
                        builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting && _isDataLoaded==false) {
                            return ListView.builder(
                              itemCount: 2, // Set the number of shimmer items
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                return ShimmerLoading.CurrentReservationShimmer(context);
                              },
                            );
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {

                            data = snapshot.data ?? [];
                            return _TreeBuild(context);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _TreeBuild (BuildContext context){
    return TabBarView(
      controller: _tabController,
      children: [
        SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: data
                .where((reservation) => reservation['reservationType'] == 'current')
                .map((reservation) {
              DateTime parsedDateTime =
              DateFormat('dd-MM-yyyy HH:mm').parse(reservation['timeBooked']);
              String formattedDateString =
              DateFormat('d-M-yyyy HH:mm').format(parsedDateTime);

              return Padding(
                padding: const EdgeInsets.only(
                  top: 10.0,
                  bottom: 10.0,
                  left: 15.0,
                  right: 15.0,
                ),
                child: CustomResCard(
                  rid: reservation['rid'],
                  reservationTime: reservation['reservationTime'],
                  reservationNumber: reservation['reservationNumber'],
                  venueName: reservation['venueName'],
                  paymentType: reservation['paymentType'],
                  imageUrl: reservation['imageUrl'],
                  reservationType: reservation['reservationType'],
                  reservationResult: reservation['reservationResult'],
                  totalAmount: reservation['totalAmount'],
                  timeRmainingInSeconds: reservation['reservationTimeRemaining'],
                  countdownDuration: reservation['reservationDuration'],
                  timeBooked: reservation['timeBooked'],
                  reservationTimeStamp: reservation['reservationTimeStamp'],
                ),
              );
            }).toList(),
          ),
        ),
        SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: data
                .where((reservation) => reservation['reservationType'] == 'old')
                .map((reservation) {
              DateTime parsedDateTime =
              DateFormat('dd-MM-yyyy HH:mm').parse(reservation['timeBooked']);
              String formattedDateString =
              DateFormat('d-M-yyyy HH:mm').format(parsedDateTime);
              return Padding(
                padding: const EdgeInsets.only(
                  top: 10.0,
                  bottom: 10.0,
                  left: 15.0,
                  right: 15.0,
                ),
                child: CustomResCard(
                  rid: reservation['rid'],
                  reservationTime: reservation['reservationTime'],
                  reservationNumber: reservation['reservationNumber'],
                  venueName: reservation['venueName'],
                  paymentType: reservation['paymentType'],
                  imageUrl: reservation['imageUrl'],
                  reservationType: reservation['reservationType'],
                  reservationResult: reservation['reservationResult'],
                  totalAmount: reservation['totalAmount'],
                  timeRmainingInSeconds: 70,
                  countdownDuration: reservation['reservationDuration'],
                  timeBooked: reservation['timeBooked'],
                  reservationTimeStamp: reservation['reservationTimeStamp'],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

}
