import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reserve/CustomWidgets/DaySchedule.dart';
import 'package:reserve/CustomWidgets/ReusableMethods.dart';
import 'package:reserve/Notifiers/SelectedLanguage.dart';
import 'package:reserve/CustomWidgets/MyCustomCalendar.dart';
import 'package:reserve/app_state.dart';
import 'package:reserve/flutter_flow/flutter_flow_model.dart';
import 'package:reserve/pages/ReservationCheckout/ReservationCheckout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'reservation_page1_model.dart';

class ReservationPage1Widget extends StatefulWidget {

  @override
  _ReservationPage1WidgetState createState() => _ReservationPage1WidgetState();
}

class _ReservationPage1WidgetState extends State<ReservationPage1Widget> {
  int counter = 0;
  late ReservationPage1Model _model;
  late String decodedCircularImg;
  late List<dynamic> decodedCircularImgList;
  late String openningTime;
  late String closingTime;
  late String cardStatus;
  Map<String, dynamic> cardData = {};
  bool isScheduleVisible = false;
  bool isPaymentVisible = false;
  bool isVacationVisible = false;
  List<String> selectedDates = [];
  String PaymentAmount = '250';
  TextEditingController paymentController = TextEditingController();


  final scaffoldKey = GlobalKey<ScaffoldState>();

  void getOpeningClosingTimesForToday(Map<String, dynamic> cardData) {
    String currentDay = DateFormat.EEEE().format(DateTime.now());

    if (cardData['weeklyStadiumOpeningSchedule'][currentDay] != null) {
      openningTime = cardData['weeklyStadiumOpeningSchedule'][currentDay][0];
      if (cardData['weeklyStadiumOpeningSchedule'][currentDay][0] != 'Closed') {
        closingTime = cardData['weeklyStadiumOpeningSchedule'][currentDay][1];
      } else {
        closingTime = 'Closed';
      }
    } else {
      openningTime = 'N/A';
      closingTime = 'N/A';
    }
  }
  // Callback to handle date selection
  void handleDateSelected(DateTime selectedDate) {
    setState(() {

      // Extract only the date part without the time
      DateTime dateWithoutTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      // Format the date without the time
      String formattedDate = DateFormat('yyyy-MM-dd').format(dateWithoutTime);
      if(!selectedDates.contains(formattedDate))
      // Add selected date to the list
      selectedDates.add(formattedDate);
    });
  }



  Future<Map<String, dynamic>?> getDocumentById(
      String collection, String documentId) async {
    try {
      var document =
      await FirebaseFirestore.instance.collection(collection).doc(documentId).get();
      return document.data();
    } catch (error) {
      print("Error fetching data: $error");
      return null;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getDocumentById('servicesInACity', '0Wq8I3H2GxaizVBUBY4r').then((data) {
      if (data != null) {
        setState(() {
          cardData = data;
          getOpeningClosingTimesForToday(cardData);
          String currentDay = DateFormat('EEEE').format(DateTime.now());
          cardStatus = ReusableMethods.determineCardStatus(
              (data['weeklyStadiumOpeningSchedule'])[currentDay] ?? []);
          decodedCircularImg = data["image"];
          decodedCircularImgList = [];
          decodedCircularImgList.add(decodedCircularImg);
        });
      }
    }).catchError((error) {
      print("Error fetching data: $error");
    });
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ReservationPage1Model());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // Function to toggle the visibility of the schedule container
  void toggleScheduleContainerVisibility() {
    setState(() {
      isScheduleVisible = !isScheduleVisible;
    });
  }
  // Function to toggle the visibility of the schedule container
  void togglePaymentContainerVisibility() {
    setState(() {
      isPaymentVisible = !isPaymentVisible;
    });
  }
  void toggleVacationContainerVisibility() {
    setState(() {
      isVacationVisible = !isVacationVisible;
    });
  }


  @override
  Widget build(BuildContext context) {
    final selectedLanguage = Provider.of<SelectedLanguage>(context);
    context.watch<FFAppState>();
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
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
          actions: [
          ],
          centerTitle: true,
          elevation: 4.0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              color: Colors.grey[100],
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    height: 210,
                    color: Colors.grey[100],
                    child: Stack(
                      children: [
                        Container(
                          height: 130,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0xFFD54D57).withOpacity(0.8),
                          ),
                        ),
                        Positioned(
                          bottom: 78.0,
                          left: 0.0,
                          right: 0.0,
                          child: Container(
                            height: 40.0,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey,
                                  width:6.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 15.0,
                          left: 100.0,
                          right: 100.0,
                          child: GestureDetector(
                            child: Container(
                              width: 160.0,
                              height: 160.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                    decodedCircularImg,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 5.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    color: Colors.grey[100],
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.0),
                      child: Center(
                        child: Text(
                          selectedLanguage
                              .translate(("" + cardData['title']).toLowerCase()),
                          style: TextStyle(
                            fontSize: 35.0,
                            fontFamily: 'Amiri',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 30.0),
                    child: Divider(
                      color: Colors.grey.withOpacity(0.6),
                      thickness: 1.2,
                    ),
                  ),
                  buildToggleContainer('Working Days', isScheduleVisible, toggleScheduleContainerVisibility, buildScheduleContainer(cardData)),
                  SizedBox(height: 20.0),
                  buildToggleContainer('Payment Settings', isPaymentVisible, togglePaymentContainerVisibility, buildpaymentContainer()),
                  SizedBox(height: 20.0),
                  buildToggleContainer('Vacation Settings', isVacationVisible, toggleVacationContainerVisibility, buildVacationContainer()),
                  SizedBox(height: 20.0,),
                ],

              ),
            ),

          ),
        ),
      ),
    );
  }

  Widget buildToggleContainer(String title, bool isVisible, void Function()? toggleVisibility, Widget content) {
    return Visibility(
      visible: !isVisible,
      child: Container(
        width: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(

          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0,right: 20.0),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Amiri',
                ),
              ),
            ),
            SizedBox(width: 8.0),
            IconButton(
              icon: Icon(
                isVisible ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 30.0,
                color:Color(0xFFD54D57) ,
              ),
              onPressed: toggleVisibility,
            ),
          ],
        ),
      ),
      replacement: content,
    );
  }
  Widget buildScheduleContainer(Map<String, dynamic> cardData) {
    return isScheduleVisible
        ? Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.grey.withOpacity(0.6),
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 5), // Adjust the offset if needed
            ),
          ],
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Days of the Week',
              style: TextStyle(
                fontSize: 25.0,
                fontFamily: 'Amiri',
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(50.0, 5.0, 50.0, 5.0),
              child: Divider(
                color: Colors.grey.withOpacity(0.6),
                thickness: 1.2,
              ),
            ),
            SizedBox(height: 10.0),
            for (String day in ['Sunday','Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'])
              Column(
                children: [
                  DaySchedule(
                    day: day,
                    hours: cardData['weeklyStadiumOpeningSchedule'][day] != null
                        ? cardData['weeklyStadiumOpeningSchedule'][day][0]
                        : 'N/A',
                  ),
                  Divider(
                    color: Colors.grey.withOpacity(0.6),
                    thickness: 1.2,
                  ),
                ],
              ),
            IconButton(
              icon: Icon(
                isScheduleVisible
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                size: 30.0,
                color:Color(0xFFD54D57),
              ),
              onPressed: toggleScheduleContainerVisibility,
            ),
          ],
        ),

      ),
    )
        : Container();
  }


  void updatePriceInFirestore(String newPrice) async {
    try {
      // Retrieve the 'sid' from shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String sid = prefs.getString('sid') ?? ''; // Provide a default value if 'sid' is not found

      // Reference to the Firestore document using 'sid'
      var documentRef = FirebaseFirestore.instance.collection('servicesInACity').doc(sid);

      // Update the 'price' field in the document
      await documentRef.update({'price': newPrice});

      // Show a success message using a Snackbar with a green background
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Price updated successfully',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Amiri',
              color: Colors.white,
              fontSize: 15,
            ),),
          duration: Duration(seconds: 2), // Optional: You can customize the duration
          backgroundColor: Colors.green, // Set the background color to green
        ),
      );

      // Show a success message or perform any other actions if needed
      print('Price updated successfully');
    } catch (error) {
      // Handle any errors that occur during the update process
      print('Error updating price: $error');
    }
  }

  Widget buildpaymentContainer() {
    return isPaymentVisible
        ? Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.grey.withOpacity(0.6),
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 5), // Adjust the offset if needed
            ),
          ],
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add your payment-related UI elements here
            Text(
              'Specify the amount of payment',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Amiri'
              ),
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.fromLTRB(50.0, 5.0, 50.0, 5.0),
              child: Divider(
                color: Colors.grey.withOpacity(0.6),
                thickness: 1.2,
              ),
            ),
            SizedBox(height: 10.0),
            Container(
              child: Text('Current Amount: ${PaymentAmount}₪',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Amiri',
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20.0,),
            Container(
              width: 150,
              height: 40,
              child: TextField(
                controller: paymentController,
                decoration: InputDecoration(
                  hintText: '100₪',
                  hintStyle: TextStyle(
                    color: Colors.grey, // Hint text color
                    fontFamily: 'Amiri',
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 50.0),
                  // Adjust vertical padding
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(
                      color: Colors.grey, // Border color when not focused
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    // Set border radius here
                    borderSide: BorderSide(
                      color: Colors.black, // Border color when focused
                    ),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Close the keyboard
                FocusScope.of(context).unfocus();
                // Retrieve the entered amount from the TextField
                String paymentAmount = paymentController.text;
                // Check if the TextField is not empty
                if (paymentAmount.isNotEmpty) {
                  // Add logic to save the payment amount
                  // Perform your saving logic here
                  // Call a function to update the price in Firestore
                  updatePriceInFirestore(paymentAmount);
                } else {
                  // Display a message or perform any action when the TextField is empty
                  print('Please enter a valid payment amount.');
                }
              },
              child: Text('Save',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Amiri',
                  fontSize: 18.0,
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: Color(0xFFD54D57),
              ),

            ),
            SizedBox(height: 10.0),
            IconButton(
              icon: Icon(
                isPaymentVisible
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                size: 30.0,
              ),
              onPressed: togglePaymentContainerVisibility,
            ),
          ],
        ),
      ),
    )
        : Container();
  }
  Widget buildVacationContainer() {
    return isVacationVisible
        ? Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.grey.withOpacity(0.6),
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 5), // Adjust the offset if needed
            ),
          ],
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Choose vacation days:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Amiri',
              ),
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.fromLTRB(50.0, 5.0, 50.0, 5.0),
              child: Divider(
                color: Colors.grey.withOpacity(0.6),
                thickness: 1.2,
              ),
            ),
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(16.0),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  MyCustomCalendar(
                    onDateSelected: handleDateSelected,
                  ),
                  SizedBox(height: 10.0),

                ],
              ),
            ),
            if (selectedDates.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Dates:',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Amiri',
                    ),
                  ),
                  SizedBox(height: 5.0),
                  for (String date in selectedDates)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          date,
                          style: TextStyle(fontSize: 14.0
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.remove_circle,
                          color: Color(0xFFD54D57),),
                          onPressed: () {
                            // Remove the selected date
                            removeDate(date);
                          },
                        ),
                      ],
                    ),
                ],
              ),
            SizedBox(height: 10.0,),
            ElevatedButton(
              onPressed: () {
                //for data base to send
                print('Selected Dates: $selectedDates');
              },
              child: Text('Save',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Amiri',
                  fontSize: 18.0,
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: Color(0xFFD54D57),
              ),
            ),
            SizedBox(height: 10.0),
            IconButton(
              icon: Icon(
                isVacationVisible
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                size: 30.0,
              ),
              onPressed: toggleVacationContainerVisibility,
            ),

          ],
        ),
      ),
    )
        : Container();
  }

  void removeDate(String date) {
    setState(() {
      selectedDates.remove(date);
    });
  }
}



