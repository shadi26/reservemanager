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
import 'package:reserve/CustomWidgets/CustomDrawer.dart';
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
  bool isContainerVisible = false;

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
    return isContainerVisible
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
            for (String day in ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'])
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
                isContainerVisible
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
      isContainerVisible = !isContainerVisible;
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
                  if (!isContainerVisible)
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
                            isContainerVisible
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

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center the content horizontally
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Center the content horizontally
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
              DropdownButton2<String>(
                isExpanded: true,
                value: selectedOption,
                onChanged: (value) {
                  setState(() {
                    selectedOption = value!;
                  });
                },
                items: ['Opened', 'Closed'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,style: TextStyle(
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
              ),
            ],
          ),

          if (selectedOption == 'Opened') ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center the content horizontally
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
                DropdownButton2<String>(
                  isExpanded: true,
                  value: selectedOpeningHour,
                  onChanged: (value) {
                    setState(() {
                      selectedOpeningHour = value!;
                    });
                  },
                  items: ['9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM', '1:00 PM', '2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value,style: TextStyle(
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
                DropdownButton2<String>(
                  isExpanded: true,
                  value: selectedClosingHour,
                  onChanged: (value) {
                    setState(() {
                      selectedClosingHour = value!;
                    });
                  },
                  items: ['9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM', '1:00 PM', '2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value,style: TextStyle(
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
                ),
              ],
            )
          ],
        ],
      ),
    );
  }
}

