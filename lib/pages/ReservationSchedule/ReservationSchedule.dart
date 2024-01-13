import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:reserve/CustomWidgets/CustomDropdown.dart';
import 'package:reserve/CustomWidgets/ShimmerLoading.dart';
import 'package:reserve/Notifiers/ReservationStatusChangedNotifier.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../CustomWidgets/CustomDrawer.dart';
import '../../Notifiers/AuthProvider.dart';
import '../../Notifiers/ReservationDoneNotifier.dart';
import '../../Notifiers/UserIdProvider.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '../../CustomWidgets/CustomResCard.dart';
import '../../Notifiers/SelectedLanguage.dart';
import 'package:intl/intl.dart';

Map<String, dynamic> mapFirebaseDataToLocal(Map<String, dynamic> firebaseData) {
  Timestamp currentTime = Timestamp.now();
  Timestamp reservationTimeStamp = firebaseData['timestamp'];
  int timeDiff = currentTime.seconds - reservationTimeStamp.seconds;
  int remainingTime = (1800 - timeDiff).abs();
  remainingTime = remainingTime.clamp(0, 1800);

  String reservationDate = firebaseData['date'];
  String reservationTime = firebaseData['time'];
  String formattedTimeStamp =
  DateFormat('dd-MM-yyyy HH:mm').format(firebaseData['timestamp'].toDate());

  String formattedDateString = '$reservationDate $reservationTime';
  DateTime reservationDateTime = DateTime.parse(
    formattedDateString.replaceAllMapped(
      RegExp(r'(\d{2})-(\d{2})-(\d{4}) (\d{2}:\d{2})'),
          (match) => '${match[3]}-${match[2]}-${match[1]} ${match[4]}',
    ),
  );

  DateTime now = DateTime.now();
  Duration timeDifference = reservationDateTime.difference(now);

  String reservationType = reservationDateTime.isBefore(now) ? 'old' : 'current';

  int randomReservationNumber = Random().nextInt(10000) + 1;
  return {
    'rid': firebaseData['documentId'],
    'reservationTime': formattedTimeStamp ?? '',
    'reservationNumber': '$randomReservationNumber',
    'venueName': firebaseData['title'] ?? '',
    'paymentType': firebaseData['paymentMethod'] ?? '',
    'imageUrl': firebaseData['image'] ?? '',
    'reservationType': reservationType,
    'reservationResult': firebaseData['status'],
    'reservationTimeRemaining': timeDiff,
    'reservationDuration': timeDifference,
    'timeBooked': '${firebaseData['date']} ${firebaseData['time']}' ?? '',
    'totalAmount': firebaseData['totalamount'],
    'reservationTimeStamp': firebaseData['timestamp'],
    'formattedDateString': formattedDateString,
    'reservationHour' : firebaseData['time'],
    'reservationDate' : firebaseData['date'],
    'reservationUserName' : firebaseData['name'],
    'reservationUserPhone' : firebaseData['phone'],
  };
}

class ReservationSchedule extends StatefulWidget {
  const ReservationSchedule({Key? key}) : super(key: key);

  @override
  _ReservationScheduleState createState() => _ReservationScheduleState();
}

class _ReservationScheduleState extends State<ReservationSchedule>
    with TickerProviderStateMixin {
  final unfocusNode = FocusNode();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> data = [];
  bool _isDataLoaded = false;
  String filter = 'All'; // Default filter value
  String dayFilter = 'All'; // Default day filter value


  Future<List<Map<String, dynamic>>> fetchReservations(String sid) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference<Map<String, dynamic>> collection =
      firestore.collection("Reservations");

      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await collection.where('sid', isEqualTo: sid).get();

      List<Map<String, dynamic>> reservations = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      return reservations;
    } catch (e) {
      print('Error fetching reservations: $e');
      return [];
    }
  }

  Future<String?> getUserId(BuildContext context) async {
    return Provider.of<UserIdProvider>(context).userId;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchDataAndMapToLocal(String sid) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference<Map<String, dynamic>> collection =
      firestore.collection("Reservations");

      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await collection.where('sid', isEqualTo: sid).get();

      List<Map<String, dynamic>> documents = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['documentId'] = doc.id;
        return data;
      }).toList();

      List<Map<String, dynamic>> mappedData = documents
          .map((document) => mapFirebaseDataToLocal(document))
          .toList();



      setState(() {
        data = mappedData;
        _isDataLoaded = true;
      });
    } catch (e) {
      print('Error fetching and mapping reservations: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    getUserId(context).then((userId) async {
      if (userId != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? savedSid = prefs.getString('sid');

        if (savedSid != null) {
          fetchDataAndMapToLocal(savedSid);
        } else {
          print('SID not found in shared preferences.');
        }
      } else {
        print('User ID is null.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
        // Listen to the notifier
        context.watch<ReservationStatusChangedNotifier>();
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
                    width: 400.0,
                    height: 100.0,
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
            body: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: 'Current'),
                      Tab(text: 'Old'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _TreeBuild(context, 'current'),
                        _TreeBuild(context, 'old'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }


  String _getDayOfWeek(String dateString) {
    DateTime parsedDateTime = DateFormat('dd-MM-yyyy HH:mm').parse(dateString);
    return DateFormat('EEEE').format(parsedDateTime);
  }
  Widget _TreeBuild(BuildContext context, String reservationType) {
    data.sort((a, b) => a['timeBooked'].compareTo(b['timeBooked']));

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text('Days:',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Amiri',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),),
                      SizedBox(width: 10.0,),
                      CustomDropdown(
                        value: dayFilter,
                        onChanged: (value) {
                          setState(() {
                            dayFilter = value!;
                          });
                        },
                          items: ['All', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Status:',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Amiri',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),),
                      SizedBox(width: 10.0,),
                      CustomDropdown(
                          value: filter,
                          onChanged: (value) {
                            setState(() {
                              filter = value!;
                            });
                          },
                          items: ['All', 'Accepted', 'Rejected']
                      ),

                    ],
                  ),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: data
                  .where((reservation) =>
              reservation['reservationType'] == reservationType &&
                  reservation['reservationResult'] != 'pending' &&
                  (filter == 'All' || reservation['reservationResult'] == filter) &&
                  (dayFilter == 'All' || _getDayOfWeek(reservation['timeBooked']) == dayFilter))
                  .map((reservation) {
                DateTime parsedDateTime =
                DateFormat('dd-MM-yyyy HH:mm').parse(reservation['timeBooked']);
                String formattedDateString =
                DateFormat('d-M-yyyy HH:mm').format(parsedDateTime);

                if (reservationType == 'current' &&
                    parsedDateTime.isAfter(DateTime.now())) {
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
                      imageUrl: 'https://cdn-icons-png.flaticon.com/128/9187/9187475.png',
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
                }

                if (reservationType == 'old' &&
                    parsedDateTime.isBefore(DateTime.now())) {
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
                      imageUrl: 'https://cdn-icons-png.flaticon.com/128/9187/9187475.png',
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
                }

                return Container();
              }).toList(),
            ),

          ),
          SizedBox(height: 20.0,),
        ],
      ),
    );
  }
}
