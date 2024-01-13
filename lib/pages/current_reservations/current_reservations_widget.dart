import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:reserve/CustomWidgets/ShimmerLoading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../CustomWidgets/CustomDrawer.dart';
import '../../Notifiers/AuthProvider.dart';
import '../../Notifiers/ReservationDoneNotifier.dart';
import '../../Notifiers/ReservationStatusChangedNotifier.dart';
import '../../Notifiers/UserIdProvider.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '../../CustomWidgets/CustomResCard.dart';
import '../../Notifiers/SelectedLanguage.dart';

Map<String, dynamic> mapFirebaseDataToLocal(Map<String, dynamic> firebaseData) {
  print('im at mapfirebasedatatolocal');
  print('firebaseData=$firebaseData');
  /************************************************************* calculating the 30 minutes difference *************************************************/
  // Get the current time
  Timestamp currentTime = Timestamp.now();
  print('currentTime=$currentTime');

  // Get the reservation timestamp from the document
  Timestamp reservationTimeStamp = firebaseData['timestamp'];
  print('reservationTimeStamp=$reservationTimeStamp');

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
    'reservationHour' : firebaseData['time'],
    'reservationDate' : firebaseData['date'],
    'reservationUserName' : firebaseData['name'],
    'reservationUserPhone' : firebaseData['phone'],
  };
}

class CurrentReservationsWidget extends StatefulWidget {
  const CurrentReservationsWidget({Key? key}) : super(key: key);

  @override
  _CurrentReservationsWidgetState createState() =>
      _CurrentReservationsWidgetState();
}

class _CurrentReservationsWidgetState extends State<CurrentReservationsWidget>
    with TickerProviderStateMixin {
  final unfocusNode = FocusNode();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> data = [];
  bool _isDataLoaded = false;
  late List<Map<String, dynamic>> documents;


  Future<String?> getUserId(BuildContext context) async {
    return Provider.of<UserIdProvider>(context).userId;
  }

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection('Reservations').snapshots().listen((snapshot) {
      // Logic to handle the new data
      setState(() {
        print('new reservation arrived');
        // Update your reservation data here
        documents = snapshot.docs.map((doc) => doc.data()).toList();
      });
    });
  }


  Future<void> fetchDataAndMapToLocal(String sid) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference<Map<String, dynamic>> collection =
      firestore.collection("Reservations");
      print('sid=$sid');

      // Fetch documents with 'sid' equal to the provided sid
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await collection.where('sid', isEqualTo: sid).get();

      print('i did get the data from firebase');

      // Extract the list of 'sid' values and document IDs from the documents
      documents = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['documentId'] = doc.id;
        return data;
      }).toList();

      // Map each document's data to the local format
      List<Map<String, dynamic>> mappedData = documents
          .map((document) => mapFirebaseDataToLocal(document))
          .toList();
      print('mappeddata=$mappedData');

      setState(() {
        data = mappedData;
        _isDataLoaded = true;
      });
    } catch (e) {
      // Handle errors if necessary
      print('Error fetching and mapping reservations: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    getUserId(context).then((userId) async {
      if (userId != null) {
        // Fetch and map reservations for the saved sid
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? savedSid = prefs.getString('sid');

        if (savedSid != null) {
          fetchDataAndMapToLocal(savedSid);
        } else {
          print('SID not found in shared preferences.');
        }
      } else {
        // Handle the case where userId is null
        print('User ID is null.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Notifier to rebuild the page when a new reservation is done
    final reservationNotifier =
    Provider.of<ReservationDoneNotifier>(context);

    final reservationStatusChanged = Provider.of<ReservationStatusChangedNotifier>(context);
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
                child: _isDataLoaded
                    ? _TreeBuild(context)
                    : ListView.builder(
                  itemCount: 2, // Set the number of shimmer items
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return ShimmerLoading.CurrentReservationShimmer(
                        context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _TreeBuild(BuildContext context) {
    // Sort the data list based on the 'timeBooked'
    data.sort((a, b) => a['timeBooked'].compareTo(b['timeBooked']));

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: data
            .where((reservation) => reservation['reservationType'] == 'current' && reservation['reservationResult'] == 'pending')
            .map((reservation) {
          DateTime parsedDateTime = DateFormat('dd-MM-yyyy HH:mm')
              .parse(reservation['timeBooked']);
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
              imageUrl:
              'https://cdn-icons-png.flaticon.com/128/9187/9187475.png',
              reservationType: reservation['reservationType'],
              reservationResult: reservation['reservationResult'],
              totalAmount: reservation['totalAmount'],
              timeRmainingInSeconds: reservation['reservationTimeRemaining'],
              countdownDuration: reservation['reservationDuration'],
              timeBooked: reservation['timeBooked'],
              reservationTimeStamp: reservation['reservationTimeStamp'],
              reservationHour: reservation['reservationHour'],
              reservationDate: reservation['reservationDate'],
              reservationUserName: reservation['reservationUserName'],
              reservationUserPhone: reservation['reservationUserPhone'],
            ),
          );
        }).toList(),
      ),
    );
  }


}
