import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reserve/CustomWidgets/ReusableMethods.dart';
import 'package:reserve/Notifiers/AuthProvider.dart';
import 'package:reserve/Notifiers/CurrentPageProvider.dart';
import 'package:reserve/Notifiers/SelectedLanguage.dart';
import 'package:reserve/Notifiers/SelectedServiceIdProvider.dart';
import 'package:reserve/Notifiers/UserIdProvider.dart';
import 'package:reserve/CustomWidgets/MyCustomCalendar.dart';
import 'package:reserve/app_state.dart';
import 'package:reserve/flutter_flow/flutter_flow_model.dart';
import 'package:reserve/pages/Login/CustomPhoneInputWidget.dart';
import 'package:reserve/pages/ReservationCheckout/ReservationCheckout.dart';
import 'reservation_page1_model.dart';

class ReservationPage1Widget extends StatefulWidget {
  List<String> imageUrls;

  ReservationPage1Widget({Key? key})
      : imageUrls = List<String>.from(cardData['imageUrls'] ?? []),
        super(key: key);

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
              ),
              onPressed: toggleScheduleContainerVisibility,
            ),
          ],
        ),

      ),
    )
        : Container();
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
              'Specify the amount of payment:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
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
              width: 200.0,
              child: TextField(
                controller: paymentController,
                decoration: InputDecoration(
                  hintText: 'Enter amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: Colors.grey.withOpacity(0.6),
                    ),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(height: 10.0),
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
                } else {
                  // Display a message or perform any action when the TextField is empty
                  print('Please enter a valid payment amount.');
                }
              },
              child: Text('Save Payment'),
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

  @override
  Widget build(BuildContext context) {
    final selectedLanguage = Provider.of<SelectedLanguage>(context);
    String serviceId =
        Provider.of<SelectedServiceIdProvider>(context).selectedServiceId ?? '';
    String userId = Provider.of<UserIdProvider>(context).userId ?? '';

    context.watch<FFAppState>();
    final authProvider = context.watch<MyAuthProvider>();
    final currentPageProvider =
    Provider.of<CurrentPageProvider>(context, listen: false);

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
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 0.0, 0.0),
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 30.0,
                ),
              ),
            ),
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
                        Positioned(
                          bottom: 78.0,
                          left: 0.0,
                          right: 0.0,
                          child: Container(
                            height: 40.0,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0.5),
                                  Colors.white.withOpacity(0.12),
                                  Colors.white.withOpacity(0.7),
                                ],
                              ),
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xFFD54D57).withOpacity(0.9),
                                  width: 5.0,
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
                                  color: Color(0xFFD54D57),
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
                            fontSize: 30.0,
                            fontFamily: 'Amiri',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Button to toggle the visibility of the schedule container
                  if (!isScheduleVisible)
                  Container(
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Working Days',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8.0),
                        IconButton(
                          icon: Icon(
                            isScheduleVisible
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 30.0,
                          ),
                          onPressed: toggleScheduleContainerVisibility,
                        ),
                      ],
                    ),
                  ),
                  buildScheduleContainer(cardData),
                  SizedBox(height: 20.0,),
                  if (!isPaymentVisible)
                    Container(
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Payment Settings',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8.0),
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
                  buildpaymentContainer(),
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
                    child: MyCustomCalendar(
                      onDateSelected: (DateTime selectedDate) {
                        setState(() {
                          _model.calendarSelectedDay = DateTimeRange(
                              start: selectedDate, end: selectedDate);
                        });
                        String? uid = Provider.of<UserIdProvider>(context, listen: false).userId;
                        if (uid == null) {
                          currentPageProvider.setCurrentPage("DateReservation");
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (BuildContext context) {
                              return CustomPhoneInputWidget();
                            },
                          );
                        } else if (counter >= 0) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (BuildContext context) {
                              return Reservationpage2Widget(
                                weeklyStadiumOpeningSchedule: cardData['weeklyStadiumOpeningSchedule'],
                                selectedDate: _model.calendarSelectedDay?.start,
                                stadImg: cardData['image'],
                                stadName: cardData['title'],
                              );
                            },
                          );
                        }
                        counter++;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomDropdown extends StatelessWidget {
  final String value;
  final Function(String) onChanged;
  final List<String> items;

  CustomDropdown({
    required this.value,
    required this.onChanged,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton2<String>(
      isExpanded: true,
      value: value,
      onChanged: (value) {
        onChanged(value!);
      },
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 18.0,
            ),
          ),
        );
      }).toList(),
      buttonStyleData: ButtonStyleData(
        height: 50.0,
        width: 100.0,
        padding: const EdgeInsets.only(left: 3.0, right: 3.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.transparent,
        ),
        elevation: 0,
      ),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 200,
        width: 100.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        offset: const Offset(0, 0),
        scrollbarTheme: ScrollbarThemeData(
          radius: const Radius.circular(20),
          thickness: MaterialStateProperty.all<double>(4),
          thumbVisibility: MaterialStateProperty.all<bool>(true),
        ),
      ),
      menuItemStyleData: const MenuItemStyleData(
        height: 30,
        padding: EdgeInsets.only(left: 10, right: 10),
      ),
    );
  }
}

class DaySchedule extends StatefulWidget {
  final String day;
  final String hours;

  DaySchedule({required this.day, required this.hours});

  @override
  _DayScheduleState createState() => _DayScheduleState();
}

class _DayScheduleState extends State<DaySchedule> {
  String selectedOption = 'Opened';
  String selectedOpeningHour = '9:00 AM';
  String selectedClosingHour = '5:00 PM';
  String separation = '0.5';
  // List to store working hours for each day
  List<Map<String, dynamic>> workingHoursMapList = [];

  // Function to save working hours to the list
  void saveWorkingHoursToList() {
    try {
      // Split the selected hours into components
      List<String> openingComponents = selectedOpeningHour.split(':');
      List<String> closingComponents = selectedClosingHour.split(':');

      // Parse hours and minutes
      int openingHour = int.parse(openingComponents[0]);
      int openingMinute = int.parse(openingComponents[1].split(' ')[0]); // Remove non-numeric characters
      String openingPeriod = openingComponents[1].split(' ')[1];

      int closingHour = int.parse(closingComponents[0]);
      int closingMinute = int.parse(closingComponents[1].split(' ')[0]); // Remove non-numeric characters
      String closingPeriod = closingComponents[1].split(' ')[1];

      // Adjust hours based on AM or PM
      if (openingPeriod == 'PM' && openingHour != 12) {
        openingHour += 12;
      }

      if (closingPeriod == 'PM' && closingHour != 12) {
        closingHour += 12;
      }

      // Calculate total opening and closing minutes
      int totalOpeningMinutes = openingHour * 60 + openingMinute;
      int totalClosingMinutes = closingHour * 60 + closingMinute;

      // Calculate working hours based on separation
      double separationHours = double.parse(separation);

      // Generate the list of separated hours
      List<String> separatedHoursList = [];
      for (int i = 0; i <= totalClosingMinutes - totalOpeningMinutes; i += (separationHours * 60).round()) {
        int currentMinute = totalOpeningMinutes + i;
        int currentHour = currentMinute ~/ 60;
        int remainingMinutes = currentMinute % 60;

        // Convert back to 12-hour format with AM or PM
        String period = currentHour < 12 ? 'AM' : 'PM';
        currentHour = currentHour % 12;
        currentHour = currentHour == 0 ? 12 : currentHour;

        separatedHoursList.add('${currentHour.toString().padLeft(2, '0')}:${remainingMinutes.toString().padLeft(2, '0')} $period');
      }

      // Save working hours data in the map
      Map<String, dynamic> workingHoursData = {
        'day': widget.day,
        'selectedOption': selectedOption,
        'selectedOpeningHour': selectedOpeningHour,
        'selectedClosingHour': selectedClosingHour,
        'separation': separation,
        'separatedHoursList': separatedHoursList,
      };

      // Add the map to the list
      workingHoursMapList.add(workingHoursData);

      // Print the working hours data
      print('Working Hours Data for ${widget.day}: $workingHoursData');
    } catch (e, stackTrace) {
      // Print the exception details for debugging
      print('Exception during parsing: $e');
      print('Stack trace: $stackTrace');
    }
  }




  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.day,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Amiri',
                ),
              ),
              SizedBox(width: 8.0),
              CustomDropdown(
                value: selectedOption,
                onChanged: (value) {
                  setState(() {
                    selectedOption = value;
                  });
                },
                items: ['Opened', 'Closed'],
              ),
            ],
          ),

          if (selectedOption == 'Opened') ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'From:',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Amiri',
                  ),
                ),
                SizedBox(width: 10.0),
                CustomDropdown(
                  value: selectedOpeningHour,
                  onChanged: (value) {
                    setState(() {
                      selectedOpeningHour = value;
                    });
                  },
                  items: ['9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM', '1:00 PM', '2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM'],
                ),
                SizedBox(width: 20.0),
                Text(
                  'To:',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Amiri',
                  ),
                ),
                SizedBox(width: 10.0),
                CustomDropdown(
                  value: selectedClosingHour,
                  onChanged: (value) {
                    setState(() {
                      selectedClosingHour = value;
                    });
                  },
                  items: ['9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM', '1:00 PM', '2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM'],
                ),
              ],
            )
          ],

          SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Separation',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Amiri',
                ),
              ),
              SizedBox(width: 10.0,),
              CustomDropdown(
                value: separation,
                onChanged: (value) {
                  setState(() {
                    separation = value;
                  });
                },
                items: ['0.5', '1.0', '1.5', '2', '2.5'],
              ),
            ],
          ),

          SizedBox(height: 10.0),
          ElevatedButton(
            onPressed: () {
              // Call the function to save working hours to the list
              saveWorkingHoursToList();
            },
            child: Text('Save Working Hours'),
          ),
        ],
      ),
    );
  }
}


