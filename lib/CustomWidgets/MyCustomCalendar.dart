import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class MyCustomCalendar extends StatefulWidget {
  final void Function(DateTime selectedDate) onDateSelected;

  MyCustomCalendar({required this.onDateSelected});

  @override
  _MyCustomCalendarState createState() => _MyCustomCalendarState();
}

class _MyCustomCalendarState extends State<MyCustomCalendar> {
  DateTime? _selectedDay;
  DateTime? _focusedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  bool _isPastDay(DateTime day) {
    return day.isBefore(DateTime.now().subtract(Duration(days: 1)));
  }

  bool isFutureDay(DateTime day) {
    return day.isAfter(DateTime.now().subtract(Duration(days: 1)));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: TableCalendar(
        locale: 'en_US',
        firstDay: DateTime.utc(2023, 1, 1),
        lastDay: DateTime.utc(2033, 12, 31),
        focusedDay: _focusedDay ?? DateTime.now(),
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        enabledDayPredicate: isFutureDay,
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
          });

          widget.onDateSelected(selectedDay);
        },
        onPageChanged: (focusedDay) {
          if (focusedDay != null) {
            // Update focusedDay only when changing the page
            setState(() {
              _focusedDay = focusedDay;
            });
          }
        },
        calendarFormat: CalendarFormat.week,
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Color(0xFFD54D57),
            shape: BoxShape.circle,
          ),
          weekNumberTextStyle: TextStyle(color: Colors.black),
          outsideTextStyle: TextStyle(color: Colors.black),
        ),
        headerStyle: HeaderStyle(
          titleTextStyle: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
