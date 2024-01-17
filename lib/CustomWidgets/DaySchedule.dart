import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reserve/CustomWidgets/CustomDropdown.dart';
import 'package:reserve/Notifiers/SelectedLanguage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DaySchedule extends StatefulWidget {
  final String day;
  final String hours;
  final String openningHour;
  final String closingHour;

  DaySchedule(
      {required this.day,
      required this.hours,
      required this.openningHour,
      required this.closingHour});

  @override
  _DayScheduleState createState() => _DayScheduleState();
}

class _DayScheduleState extends State<DaySchedule> {
  late List<String> timeOptions;
  late String selectedOption ;
  late String selectedOpeningHour ;
  late String selectedClosingHour ;
  String separation = '0.5';

  // List to store working hours for each day
  List<Map<String, dynamic>> workingHoursMapList = [];

  void updateStadiumOpeningHours() async {
    final prefs = await SharedPreferences.getInstance();
    String sid = prefs.getString('sid') ?? '';

    if (sid.isNotEmpty) {
      // Assume openingHour is the value you want to update

      List<String> openingClosingHours = [selectedOpeningHour, selectedClosingHour];

      FirebaseFirestore.instance
          .collection('servicesInACity')
          .doc(sid)
          .update({
            'weeklyStadiumOpeningSchedule.${widget.day}': openingClosingHours
          })
          .then((_) => print("Schedule updated successfully"))
          .catchError((error) => print("Failed to update schedule: $error"));
    } else {
      print("No SID found in Shared Preferences");
    }
  }

  @override
  void initState() {
    super.initState();
    selectedOpeningHour = widget.openningHour;
    selectedClosingHour = widget.closingHour;


    // Initialize time options with half hour difference between them
    timeOptions = [
      for (int h = 0; h < 24; h++)
        for (int m = 0; m < 60; m += 30)
          '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}'
    ];
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize selectedOption based on widget.openningHour
    selectedOption = widget.openningHour == 'Closed'
        ? Provider.of<SelectedLanguage>(context).translate('closed')
        : Provider.of<SelectedLanguage>(context).translate('open');

  }
  // Function to save working hours to the list
  void saveWorkingHoursToList() {
    final selectedLanguage = Provider.of<SelectedLanguage>(context);
    try {
      // Split the selected hours into components
      List<String> openingComponents = selectedOpeningHour.split(':');
      List<String> closingComponents = selectedClosingHour.split(':');

      // Parse hours and minutes
      int openingHour = int.parse(openingComponents[0]);
      int openingMinute = int.parse(
          openingComponents[1].split(' ')[0]); // Remove non-numeric characters
      String openingPeriod = openingComponents[1].split(' ')[1];

      int closingHour = int.parse(closingComponents[0]);
      int closingMinute = int.parse(
          closingComponents[1].split(' ')[0]); // Remove non-numeric characters
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
      for (int i = 0;
          i <= totalClosingMinutes - totalOpeningMinutes;
          i += (separationHours * 60).round()) {
        int currentMinute = totalOpeningMinutes + i;
        int currentHour = currentMinute ~/ 60;
        int remainingMinutes = currentMinute % 60;

        // Convert back to 12-hour format with AM or PM
        String period = currentHour < 12 ? 'AM' : 'PM';
        currentHour = currentHour % 12;
        currentHour = currentHour == 0 ? 12 : currentHour;

        separatedHoursList.add(
            '${currentHour.toString().padLeft(2, '0')}:${remainingMinutes.toString().padLeft(2, '0')} $period');
      }

      // Save working hours data in the map
      Map<String, dynamic> workingHoursData = {
        'day': widget.day,
        'selectedOption': selectedLanguage.translate(selectedOption),
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
    final selectedLanguage = Provider.of<SelectedLanguage>(context);
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                selectedLanguage.translate((widget.day).toLowerCase()),
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Amiri',
                ),
              ),
              SizedBox(width: 8.0),
              CustomDropdown(
                value: selectedLanguage.translate(selectedOption),
                onChanged: (value) {
                  setState(() {
                    selectedOption = value!;
                  });
                },
                items: [selectedLanguage.translate('open'),
                  selectedLanguage.translate('closed')],
              ),
            ],
          ),
          if (selectedOption == selectedLanguage.translate('open')) ...[
            Row(
              children: [
                Text(
    selectedLanguage.translate('from')+": ",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Amiri',
                  ),
                ),
                SizedBox(width: 10.0),
                Expanded(
                  child: CustomDropdown(
                      value: selectedOpeningHour,
                      onChanged: (value) {
                        setState(() {
                          selectedOpeningHour = value;
                          print('selectedOpeningHours=$selectedOpeningHour');
                        });
                      },
                      items: timeOptions),
                ),
                SizedBox(width: 20.0),
                Text(
                  selectedLanguage.translate('to')+': ',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Amiri',
                  ),
                ),
                SizedBox(width: 10.0),
                Expanded(
                  child: CustomDropdown(
                      value: selectedClosingHour,
                      onChanged: (value) {
                        setState(() {
                          selectedClosingHour = value;
                        });
                      },
                      items: timeOptions),
                ),
              ],
            )
          ],
          SizedBox(height: 10.0),
          ElevatedButton(
            onPressed: () {
              // Call the function to save working hours to the list
              saveWorkingHoursToList();
              updateStadiumOpeningHours();
            },
            child: Text(
    selectedLanguage.translate('savebtn'),
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
        ],
      ),
    );
  }
}
