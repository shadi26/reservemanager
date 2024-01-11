import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:reserve/pages/ServiceSelection/ServiceSelection.dart';
import '../../CustomWidgets/CustomDrawer.dart';
import '../../CustomWidgets/MyCarouselWithDots.dart';
import '../../CustomWidgets/MyCustomCalendar.dart';
import '../../Notifiers/AuthProvider.dart';
import '../../Notifiers/CurrentPageProvider.dart';
import '../../Notifiers/SelectedServiceIdProvider.dart';
import '../../Notifiers/UserIdProvider.dart';
import '../Login/CustomPhoneInputWidget.dart';
import '../ReservationCheckout/ReservationCheckout.dart';
import '../../CustomWidgets/ReusableMethods.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'reservation_page1_model.dart';
export 'reservation_page1_model.dart';
import '../../Notifiers/SelectedLanguage.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

List<Map<String, dynamic>> cardDetails = [

];

class ReservationPage1Widget extends StatefulWidget {
  List<String> imageUrls;

  ReservationPage1Widget(
      {Key? key})
      : imageUrls = List<String>.from(cardData['imageUrls'] ?? []),
        super(key: key);

  @override
  _ReservationPage1WidgetState createState() => _ReservationPage1WidgetState();
}

class _ReservationPage1WidgetState extends State<ReservationPage1Widget> {
  int counter =
      0; // counter for the times day changed so it does nothing on first time
  late ReservationPage1Model _model;
  late List<Uint8List> decodedImages;
  late String decodedCircularImg;
  late List<dynamic> decodedCircularImgList;
  late String openningTime;
  late String closingTime;
  late String cardStatus;
  Map<String, dynamic> cardData = {};

  // Access the SelectedServiceIdProvider using Provider.of

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Add this function inside the _ReservationPage1WidgetState class
  void getOpeningClosingTimesForToday() {
    // Format full day name (e.g., 'Monday', 'Tuesday', etc.)
    String currentDay = DateFormat.EEEE().format(DateTime.now());

    // Check if the current day exists in the schedule
    if (cardData['weeklyStadiumOpeningSchedule'][currentDay] != null) {
      // Get the opening and closing times for today
      openningTime =
          cardData['weeklyStadiumOpeningSchedule'][currentDay][0];
      if (cardData['weeklyStadiumOpeningSchedule'][currentDay][0] !=
          'Closed')
        closingTime =
            cardData['weeklyStadiumOpeningSchedule'][currentDay][1];
      else
        closingTime = 'Closed';
    } else {
      // Set default values if no schedule is available for the current day
      openningTime = 'N/A';
      closingTime = 'N/A';
    }
  }

  String capitalize(String input) {
    if (input == null || input.isEmpty) {
      return input;
    }
    return input[0].toUpperCase() + input.substring(1);
  }

  Future<void> launchWazeRoute(double lat, double lng) async {
    var url = 'waze://?ll=$lat,$lng&navigate=yes';
    var fallbackUrl =
        'https://www.waze.com/ul?ll=$lat,$lng&navigate=yes&zoom=17';
    try {
      if (await url_launcher.canLaunchUrl(Uri.parse(url))) {
        await url_launcher.launchUrl(Uri.parse(url));
      } else {
        print('Cannot launch Waze, falling back to the fallback URL');
        await url_launcher.launchUrl(Uri.parse(fallbackUrl));
      }
    } catch (e) {
      print('Failed to launch Waze, falling back to the fallback URL');
      await url_launcher.launchUrl(Uri.parse(fallbackUrl));
    }
  }

  void showOpeningHoursDialog(
      BuildContext context, Map<String, dynamic> weeklySchedule) {
    // Get the selected language from the provider
    final selectedLanguage =
        Provider.of<SelectedLanguage>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFD54D57), // Set the background color
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              // Set to min to avoid additional space
              children: [
                Center(
                  child: Text(
                    selectedLanguage.translate('workinghours'),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Amiri', // Set the font family
                    ),
                  ),
                ),
                Divider(color: Colors.white), // Set divider color
                IntrinsicHeight(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(7, (index) {
                      String day = [
                        selectedLanguage.translate('sunday'),
                        selectedLanguage.translate('monday'),
                        selectedLanguage.translate('tuesday'),
                        selectedLanguage.translate('wednesday'),
                        selectedLanguage.translate('thursday'),
                        selectedLanguage.translate('friday'),
                        selectedLanguage.translate('saturday'),
                      ][index];

                      List<dynamic> openingHours = weeklySchedule[
                              capitalize(selectedLanguage.untranslate(day))] ??
                          [];

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              day,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Amiri', // Set the font family
                              ),
                            ),
                            Column(
                              children: [
                                if (openingHours.isNotEmpty)
                                  Text(
                                    openingHours.join(' - '),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontFamily:
                                          'Amiri', // Set the font family
                                    ),
                                  ),
                                if (openingHours.isEmpty)
                                  Center(
                                    child: Text(
                                      'Closed',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontFamily:
                                            'Amiri', // Set the font family
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData getIconData(String iconName) {
    // Map to associate icon names with IconData
    Map<String, IconData> iconMap = {
      'sports_soccer': Icons.sports_soccer,
      'directions_run': Icons.directions_run,
      'people': Icons.people,
      // Add more icons as needed
    };
    // Check if the iconName exists in the map
    if (iconMap.containsKey(iconName)) {
      return iconMap[iconName]!;
    } else {
      // If the iconName is not found, return a default icon (you can change this as needed)
      return Icons.error;
    }
  }
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getDocumentById(String collection, String documentId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(collection).doc(documentId).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print("Error fetching document: $e");
      return null;
    }
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getDocumentById('servicesInACity', '0Wq8I3H2GxaizVBUBY4r').then((data) {
      if (data != null) {
        setState(() {
          cardData=data;

          // Processing "cardDetails"
          List<dynamic> dataFromDatabase = data["cardDetails"];
          List<Map<String, dynamic>> listOfMaps = dataFromDatabase.cast<Map<String, dynamic>>();

          List<Map<String, dynamic>> updatedCardDetails = listOfMaps.map((e) {
            if (!e['icon'].toString().startsWith("IconData")) {
              e['icon'] = getIconData(e['icon'].toString());
            }
            return e;
          }).toList();
          cardDetails = updatedCardDetails;

          // Additional processing...
          String currentDay = DateFormat('EEEE').format(DateTime.now());
          cardStatus = ReusableMethods.determineCardStatus(
              (data['weeklyStadiumOpeningSchedule'])[currentDay] ?? []);

          decodedCircularImg = data["image"];
          decodedCircularImgList = [];
          decodedCircularImgList.add(decodedCircularImg);

          // More processing as needed
          getOpeningClosingTimesForToday();
        });
      }
    }).catchError((error) {
      // Handle any errors here
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

  @override
  Widget build(BuildContext context) {
    // Get the selected language from the provider
    final selectedLanguage = Provider.of<SelectedLanguage>(context);
    // Access the SelectedServiceIdProvider using Provider.of
    String serviceId =
        Provider.of<SelectedServiceIdProvider>(context).selectedServiceId ?? '';
    // Access the UserIdProvider using Provider.of
    String userId = Provider.of<UserIdProvider>(context).userId ?? '';
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
    final currentPageProvider =
        Provider.of<CurrentPageProvider>(context, listen: false);
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.grey[100],
        // Set the background color to white
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
              padding: EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 0.0, 0.0),
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  Navigator.pop(
                      context); // This line will pop the current screen off the stack
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
        drawer: CustomDrawer(
          isAuthenticated: authProvider.isAuthenticated,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              color: Colors.grey[100], // Adjust opacity as needed
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Container containing the image carousel and profile icon
                  Container(
                    width: double.infinity,
                    height: 310,
                    color: Colors.grey[100], // Adjust opacity as needed
                    child: Stack(
                      children: [
                        MyCarouselWithDots(
                          imageUrls: cardData['imageUrls'],
                          autoPlayImg: false,
                          enableEnlargeView: true,
                          dotPosition: DotPosition.top,
                        ),

                        //white container above the carousel
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
                                  Colors.white.withOpacity(0.0),
                                  // Transparent at the top
                                  Colors.white.withOpacity(0.12),
                                  // Half transparent in the middle
                                  Colors.white.withOpacity(0.7),
                                  // Almost fully opaque at the bottom
                                ],
                              ),
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xFFD54D57).withOpacity(0.9),
                                  width: 5.0,
                                ),
                              ),
                            ),
                            // Add your content for the container here
                          ),
                        ),

                        //conatiner for open or closed
                        Positioned(
                          left: 30.0,
                          bottom: 65.0,
                          child: Container(
                            height: 35,
                            width: 70,
                            decoration: BoxDecoration(
                              color: cardStatus != 'closed'
                                  ? Color(0xFF98CA05)
                                  : Color(0xFFBE0133),
                              // Set your desired background color
                              borderRadius: BorderRadius.circular(
                                  20.0), // Set your desired border radius
                            ),
                            child: Center(
                              child: Text(
                                selectedLanguage.translate(cardStatus),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Amiri',
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        //container for working time
                        Positioned(
                          bottom: 65.0,
                          right: 10.0,
                          child: GestureDetector(
                            onTap: () {
                              showOpeningHoursDialog(
                                  context,
                                  cardData[
                                      'weeklyStadiumOpeningSchedule']);
                            },
                            child: Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Color(0xFFD54D57),
                                // Set your desired background color
                                borderRadius: BorderRadius.circular(
                                    20.0), // Set your desired border radius
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/icons/clock.png',
                                    height: 16.0,
                                    // Adjust the height of the icon as needed
                                    width:
                                        16.0, // Adjust the width of the icon as needed
                                  ),
                                  SizedBox(
                                    width: 5.0,
                                  ),
                                  Text(
                                    openningTime != 'Closed'
                                        ? '$openningTime-$closingTime'
                                        : selectedLanguage.translate('closed'),
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      fontFamily: 'Amiri',
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
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
                                  image: CachedNetworkImageProvider(decodedCircularImg) ,
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

                  // Container with stadium name
                  Container(
                    width: double.infinity,
                    color: Colors.grey[100], // Adjust opacity as needed
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.0),
                      child: Center(
                        child: Text(
                          selectedLanguage.translate(
                              ("" + cardData['title']).toLowerCase()),
                          style: TextStyle(
                            fontSize: 30.0,
                            fontFamily: 'Amiri',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Container with location
                  Container(
                    width: double.infinity,
                    color: Colors.grey[100], // Adjust opacity as needed
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 0.0),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                launchWazeRoute(
                                    32.808109644013044, 35.17401210979948);
                                // Add your functionality here
                                // For example, you can navigate to a new screen or perform some action
                                // when the Waze icon is clicked
                              },
                              child: Image.asset(
                                'assets/icons/wazeIcon.png',
                                width: 30.0,
                                height: 30.0,
                              ),
                            ),
                            SizedBox(width: 10.0),
                            Text(
                              selectedLanguage.translate(
                                  ("" + cardData['city']).toLowerCase()),
                              style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 16.0,
                                  color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Container containing the cards
                  Container(
                    width: double.infinity,
                    color: Colors.grey[100], // Adjust opacity as needed
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 15.0),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: cardDetails.map((card) {
                            return Padding(
                              padding: EdgeInsets.all(8.0),
                              child: _buildCard(
                                card["title"],
                                card["icon"],
                                card["isAvailable"],
                                card["number"],
                                card['tip'],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),

                  // New container with calendar
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
                        String? uid =
                            Provider.of<UserIdProvider>(context, listen: false)
                                .userId;
                        // Get the selected payment method from the PaymentMethodNotifier
                        if (uid == null) {
                          currentPageProvider.setCurrentPage("DateReservation");
                          // Add your Phone login logic here
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            // Allow the bottom sheet to take up the full screen height
                            builder: (BuildContext context) {
                              // Return the widget that you want to show
                              return CustomPhoneInputWidget();
                            },
                          );
                        } else if (counter >= 0) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (BuildContext context) {
                              return Reservationpage2Widget(
                                weeklyStadiumOpeningSchedule:
                                    cardData['weeklyStadiumOpeningSchedule'],
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

Widget _buildCard(
    String title, IconData icon, bool isAvailable, int number, String tip) {
  final GlobalKey<TooltipState> tooltipKey = GlobalKey<TooltipState>();

  return GestureDetector(
    onTap: () {
      tooltipKey.currentState?.ensureTooltipVisible();
    },
    child: Tooltip(
      key: tooltipKey,
      message: tip,
      preferBelow: false,
      child: Container(
        width: 70, // Adjust the size of the card as needed
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 30.0,
              color: Colors.grey,
            ),
            SizedBox(height: 5.0),
            if (isAvailable)
              Icon(
                Icons.check,
                size: 15.0,
                color: Colors.green,
              )
            else
              Text(
                number.toString(),
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
