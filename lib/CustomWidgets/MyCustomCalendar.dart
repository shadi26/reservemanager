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

  bool isNotPastOrFuture14Days(DateTime day) {
    DateTime fourteenDaysFromNow = DateTime.now().add(Duration(days: 14));
    return !(_isPastDay(day) || day.isAfter(fourteenDaysFromNow));
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
        enabledDayPredicate: isNotPastOrFuture14Days,
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = DateTime.now();
          });

          widget.onDateSelected(selectedDay);
        },
        onPageChanged: (focusedDay) {
          if (focusedDay != null) {
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
          weekNumberTextStyle:TextStyle(color: Colors.black),
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
