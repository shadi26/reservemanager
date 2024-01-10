import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:reserve/CustomWidgets/CustomConfirmationDialog.dart';
import 'creditCardDialog.dart';
import '../../Notifiers/ReservationDoneNotifier.dart';
import '../../Notifiers/SelectedLanguage.dart';
import '../../Notifiers/PaymentMethodNotifier.dart';
import '../../CustomWidgets/CustomeDropdownMenu.dart';
import '../../Notifiers/SelectedServiceIdProvider.dart';
import '../../Notifiers/UserIdProvider.dart';
import 'package:audioplayers/audioplayers.dart';

Map<String, dynamic> cardData = {
  'stadImg': '',
  'stadName': '',
  'dateChosen': ''
};

class Reservationpage2Widget extends StatefulWidget {
  final Map<String, dynamic> weeklyStadiumOpeningSchedule;
  final DateTime? selectedDate;
  final String stadImg; // New parameter
  final String stadName; // New parameter

  Reservationpage2Widget({
    Key? key,
    required this.weeklyStadiumOpeningSchedule,
    this.selectedDate,
    required this.stadImg,
    required this.stadName,
  }) : super(key: key);

  @override
  _Reservationpage2WidgetState createState() => _Reservationpage2WidgetState();
}

class _Reservationpage2WidgetState extends State<Reservationpage2Widget> {
  String selectedPaymentMethod = '';
  bool isCreditCardClicked = false;
  String _priceAmount = '250';
  AudioPlayer _audioPlayer = AudioPlayer();
  List<Map<String, dynamic>> reservations = [];
  List<String> hoursList = [];
  late String? selectedHour;
  String totalAmount = '';

  //is the credit card service available should be changed to true
  bool isCreditCardAvailable = false;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  Future<void> playSuccessSound() async {
    try {
      // Play the success sound effect
      final player = AudioPlayer();
      await player.play(AssetSource('audios/success-sound.wav'));
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  Future<void> addNewReservation(
    String sid,
    String uid,
    String selectedpaymentMethod,
    ReservationDoneNotifier reservationNotifier,
    SelectedLanguage selectedLanguage,
  ) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference reservationsCollection =
          firestore.collection("Reservations");

      // Add a new document to the "Reservations" collection with server timestamp
      await reservationsCollection.add({
        'date': formatDate(widget.selectedDate),
        'day': DateFormat('EEEE').format(widget.selectedDate!),
        'sid': sid,
        'time': selectedHour,
        'uid': uid,
        'totalamount': _priceAmount,
        'paymentMethod': selectedpaymentMethod,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      }).then((_) {
        // Play the success sound effect
        playSuccessSound();

        // Show local notification
        showLocalNotification('Your reservation was successful!');

        // Display a success message or navigate to the next screen
        final snackBar = SnackBar(
          content: Text(
            selectedLanguage.translate('bookingsuccessful'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Amiri',
              color: Colors.white,
              fontSize: 15,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: Colors.green[400]!,
          duration: Duration(seconds: 2),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        reservationNotifier.notifyReservationDone();
        // Close the ModalBottomSheet
        Navigator.pop(context);
      });
    } catch (e) {
      // Handle errors if necessary
      print('Error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchDataFromFirebase(
      String collectionName) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference collection = firestore.collection(collectionName);
      QuerySnapshot querySnapshot = await collection.get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      // Handle errors if necessary
      print('Error fetching data: $e');
      return [];
    }
  }

  Future<void> fetchDataFromFirebase() async {
    try {
      List<Map<String, dynamic>> data =
          await _fetchDataFromFirebase("Reservations");
      setState(() {
        reservations = data;
      });
    } catch (e) {
      // Handle errors if necessary
      print('Error fetching data: $e');
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'No Date'; // Handle null dates

    DateFormat formatter = DateFormat('dd-MM-yyyy');
    return formatter.format(date);
  }

  void updateHoursList() {
    List<String> newHoursList =
    getTimeSlotsForSelectedDate(widget.weeklyStadiumOpeningSchedule);

    DateTime now = DateTime.now();
    String currentTime = DateFormat('HH:mm').format(now);

    setState(() {
      // Filter out the hours that have passed , only if the day chosen is today
      if( isSameDay(DateTime.now(),widget.selectedDate!) )
      newHoursList = newHoursList.where((hour) => isTimeAfter(now, hour)).toList();

      hoursList = newHoursList;

      if (hoursList.isNotEmpty) {
        selectedHour = hoursList[0];
      } else {
        selectedHour = null;
      }
    });
  }

  Future<void> _saveFCMTokenToFirebase(String? fcmToken) async {
    try {
      if (fcmToken != null) {
        // Get the uid from the UserIdProvider
        String? uid =
            Provider.of<UserIdProvider>(context, listen: false).userId;

        if (uid != null) {
          FirebaseFirestore firestore = FirebaseFirestore.instance;
          DocumentReference userDocRef = firestore.collection('users').doc(uid);

          // Update the FCM token for the user
          await userDocRef.update({
            'fcmToken': fcmToken,
          });
        }
      }
    } catch (e) {
      print('Error saving FCM token to Firebase: $e');
    }
  }

  List<String> generateTimeSlots(String startTime, String endTime) {
    DateTime start = _parseTime(startTime);
    DateTime end = _parseTime(endTime);
    List<String> timeSlots = [];

    while (start.isBefore(end)) {
      timeSlots.add(_formatTime(start));
      start = start.add(Duration(minutes: 90)); // Adding 1.5 hours
    }

    return timeSlots;
  }

  List<String> getTimeSlotsForSelectedDate(
      Map<String, dynamic> weeklyOpeningDays) {
    String selectedDay = widget.selectedDate != null
        ? DateFormat('EEEE').format(widget.selectedDate!)
        : '';

    var selectedDaySchedule = weeklyOpeningDays[selectedDay];

    if (selectedDaySchedule is! List<dynamic> || selectedDaySchedule.isEmpty) {
      return [];
    }

    if (selectedDaySchedule[0] == 'Closed') {
      return [];
    }

    String startTime = selectedDaySchedule[0];
    String endTime = selectedDaySchedule[1];

    return generateTimeSlots(startTime, endTime);
  }

  DateTime _parseTime(String time) {
    int hour = int.parse(time.split(':')[0]);
    int minute = int.parse(time.split(':')[1]);
    return DateTime(0, 0, 0, hour, minute);
  }

  String _formatTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  Future<void> _configureFirebaseMessaging() async {
    _firebaseMessaging.setAutoInitEnabled(true);
    // Configure FCM
    final fcmToken = await FirebaseMessaging.instance.getToken();

    await _firebaseMessaging.requestPermission(provisional: true);
    _firebaseMessaging.subscribeToTopic('reservations');

    // Save the FCM token for the user in Firestore or Realtime Database
    await _saveFCMTokenToFirebase(fcmToken);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle notification when the app is in the foreground
      showLocalNotification(message.notification?.body ?? '');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle notification when the app is in the background and opened by tapping the notification
      // Add your logic to navigate to the relevant screen when the notification is tapped
    });
  }

  //

  void showLocalNotification(String message) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'afs3', // Change this to a unique channel ID
      'afs3', // Change this to a unique channel name
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    _flutterLocalNotificationsPlugin.show(
      0, // Change this to a unique ID
      'Reservation pending for acceptance',
      message,
      platformChannelSpecifics,
      payload: 'reservations',
    );
  }

  bool isTimeAfter(DateTime dateTime, String timeString) {
    // Convert the timeString to DateTime
    List<String> timeParts = timeString.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);

    DateTime timeToCompare = DateTime(dateTime.year, dateTime.month, dateTime.day, hour, minute);

    // Compare the hours and minutes
    return dateTime.isBefore(timeToCompare);
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return DateFormat('yyyy-MM-dd').format(date1) ==
        DateFormat('yyyy-MM-dd').format(date2);
  }

  @override
  void initState() {
    super.initState();
    _configureFirebaseMessaging();

    // Initialize FlutterLocalNotificationsPlugin
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');
    final InitializationSettings initializationSettings =
        new InitializationSettings(android: initializationSettingsAndroid);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    updateHoursList();
    cardData['dateChosen'] = formatDate(widget.selectedDate);
    cardData['stadName'] = widget.stadName;

    fetchDataFromFirebase().then((_) {
      // Get the sid from the provider
      SelectedServiceIdProvider selectedServiceIdProvider =
          Provider.of<SelectedServiceIdProvider>(context, listen: false);
      String? sid = selectedServiceIdProvider.selectedServiceId;

      UserIdProvider userIdProvider =
          Provider.of<UserIdProvider>(context, listen: false);
      String? uid = userIdProvider.userId;

      // Get the current day and time
      DateTime now = DateTime.now();
      String currentDay = DateFormat('EEEE').format(now);
      int currentHour = now.hour;
      // enter here just if the selected day is today , to remove the passed hours

      for (Map<String, dynamic> reservation in reservations) {
        if (hoursList.contains(reservation['time']) &&
            reservation['sid'] == sid &&
            reservation['date'] == formatDate(widget.selectedDate)) {
          setState(() {
            hoursList.remove(reservation['time']);
            // if statement to fix the bug of selecting first element of dropdown menu
            // change the selectedHour to the new List value in index [0]
            if (selectedHour == reservation['time'])
              selectedHour = hoursList[0];
          });
        }
      }
    });
  }

  Widget buildAmountRow(BuildContext context) {
    // Add the BuildContext parameter
    final selectedLanguage = Provider.of<SelectedLanguage>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 0.0),
          child: Text(
            selectedLanguage.translate('amount'),
            style: TextStyle(
              fontFamily: 'Amiri',
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 0.0),
          child: Text(
            _priceAmount.toString() + ' ₪',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    //notifier to rebuild the current_reservations page when the customer makes new reservation
    final reservationNotifier = Provider.of<ReservationDoneNotifier>(context);
    // Get the selected language from the provider
    final selectedLanguage = Provider.of<SelectedLanguage>(context);
    var paymentMethodNotifier = Provider.of<PaymentMethodNotifier>(context);

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFFD54D57), // Red color
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        right: 0,
                        child: IconButton(
                          onPressed: () {
                            // Navigate back when the icon is clicked
                            Navigator.pop(context);
                          },
                          icon: Image.asset(
                            'assets/icons/Xbtn.png',
                            width: 16.0, // Set the desired width of the image
                            height: 16.0, // Set the desired height of the image
                          ),
                        ),
                      ),
                      Text(
                        selectedLanguage.translate('checkout'),
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Amiri',
                          fontSize: 22.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(90.0, 20.0, 90.0, 20.0),
                  child: Row(
                    children: [
                      Text(
                        selectedLanguage.translate('selecttime') + ':',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 5.0,
                      ),
                      CustomDropdownMenu(
                        items: hoursList,
                        value: selectedHour,
                        menuWidth: 100,
                        menuHeight: 35,
                        menuColor: Color(0xFFD54D57),
                        buttonColor: Color(0xFFD54D57),
                        textColor: Colors.white,
                        textFont: 18.0,
                        buttonElevated: 0,
                        defaultTextColor: Colors.grey,
                        //animatedText: false,
                        onChanged: (hour) {
                          setState(() {
                            selectedHour = hour;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 0.0),
              child: Container(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        selectedLanguage.translate('selectpayment') + ':',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(70.0, 0.0, 70.0, 10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 30.0,
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                selectedPaymentMethod = 'cash';
                              });
                            },
                            child: Stack(
                              children: [
                                Container(
                                  width: 110.0,
                                  height: 100.0,
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      Center(
                                        child: Transform.scale(
                                          scale: 1.5,
                                          child: Image.asset(
                                            'assets/icons/cashicon.png',
                                            width: 40,
                                            height: 40,
                                          ),
                                        ),
                                      ),
                                      if (selectedPaymentMethod ==
                                          'cash')
                                        Positioned(
                                          top: 0.0,
                                          child: Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 30,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  bottom: 0.0,
                                  left: selectedLanguage.selectedLanguage =='English'? 35.0 :0.0,
                                  right: selectedLanguage.selectedLanguage =='English'? 0.0 : 38.0,
                                  child: Text(
                                    selectedLanguage.translate('cashmethod'),
                                    style: TextStyle(
                                        fontFamily: 'Amiri',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 5.0),
                          Container(
                            child: Stack(
                              children: [
                                Container(
                                  height: 100.0,
                                  width: 110.0,
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      Center(
                                        child: Transform.scale(
                                          scale: 1.40,
                                          child: Image.asset(
                                            'assets/icons/bank-card.png',
                                            width: 40,
                                            height: 40,
                                            color: isCreditCardAvailable
                                                ? null
                                                : Colors.grey.withOpacity(0.5),
                                          ),
                                        ),
                                      ),
                                      if (isCreditCardAvailable &&
                                          selectedPaymentMethod == 'creditCard')
                                        Positioned(
                                          top: 0.0,
                                          child: Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 30,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  bottom: 0.0,
                                  left: selectedLanguage.selectedLanguage =='English'? 15.0 :0.0,
                                  right: selectedLanguage.selectedLanguage =='English'? 0.0 :30.0,
                                  child: Text(
                                    selectedLanguage.translate('creditcardmethod'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Amiri',
                                      fontSize: 16,
                                      color: isCreditCardAvailable
                                          ? Colors.black
                                          : Colors.grey.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              color: Colors.grey,
              height: 30,
              thickness: 1,
              indent: 50,
              endIndent: 50,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: buildAmountRow(context),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Container(
                width: 300, // Adjust the width as needed
                height: 40,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Shadow color
                      spreadRadius: 2, // Spread radius
                      blurRadius: 4, // Blur radius
                      offset: Offset(0, 2), // Offset in x and y
                    ),
                  ],
                  borderRadius: BorderRadius.circular(
                      50), // Adjust the border radius as needed
                ),
                child: FloatingActionButton(
                  onPressed: () async {
                    // Get the sid from the SelectedServiceIdProvider
                    String? sid = Provider.of<SelectedServiceIdProvider>(
                            context,
                            listen: false)
                        .selectedServiceId;
                    // Get the uid from the UserIdProvider
                    String? uid =
                        Provider.of<UserIdProvider>(context, listen: false)
                            .userId;
                    // Get the selected payment method from the PaymentMethodNotifier
                          selectedPaymentMethod;
                    if (selectedPaymentMethod == 'cash' &&
                        selectedHour != null &&
                        selectedPaymentMethod.isNotEmpty &&
                        sid != null)
                      ConfirmationDialog.show(
                        context: context,
                        title:
                            selectedLanguage.translate('bookingconfirmation'),
                        content: selectedLanguage
                            .translate('bookingConfirmationText'),
                        confirmButtonText: selectedLanguage.translate('yesbtn'),
                        cancelButtonText: selectedLanguage.translate('nobtn'),
                        onConfirm: () async {
                          await addNewReservation(
                              sid!,
                              uid!,
                              selectedPaymentMethod,
                              reservationNotifier,
                              selectedLanguage);

                          Navigator.pop(context);
                        },
                      );
                    else if (selectedPaymentMethod == 'creditCard' &&
                        selectedHour != null &&
                        selectedPaymentMethod.isNotEmpty &&
                        sid != null)
                      return CreditCardEntryDialog.showCreditCardEntryDialog(
                          context);
                    else {
                      // Show an error message if the hour, payment method, or sid is not selected
                      final snackBar = SnackBar(
                        content: Text(
                          selectedLanguage.translate('selectpaymentandtime'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        backgroundColor: Colors.red[400]!,
                        duration: Duration(seconds: 2),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  },
                  child: Text(
                    selectedLanguage.translate('bookbtn'),
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  backgroundColor: Color(0xFFD54D57),
                  elevation:
                      1, // Set elevation to 0 to remove default button shadow
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
