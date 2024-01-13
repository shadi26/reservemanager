import 'package:flutter/material.dart';
import 'package:reserve/CustomWidgets/CustomDropdown.dart';

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

  @override
  void initState() {
    super.initState();
    print('hours=${widget.hours}');
    print('day=${widget.day}');


  }

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
        ],
      ),
    );
  }
}
