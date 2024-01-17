import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reserve/Notifiers/SelectedLanguage.dart';

class CountdownTimer extends StatefulWidget {
  final Duration startTime;

  CountdownTimer({
    Key? key,

    required this.startTime,
  }): super(key: key ?? UniqueKey()); // Use UniqueKey to ensure a unique key

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  late int _remainingSeconds;

  @override
  void initState() {
    super.initState();
    _remainingSeconds =  widget.startTime.inSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds -= 1;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedLanguage = Provider.of<SelectedLanguage>(context);

    int days = _remainingSeconds ~/ (24 * 3600);
    int hours = (_remainingSeconds % (24 * 3600)) ~/ 3600;
    int minutes = (_remainingSeconds % 3600) ~/ 60;
    int seconds = _remainingSeconds % 60;

    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300] ?? Colors.black),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTimeUnit(days, selectedLanguage.translate('days')),
          _buildDivider(),
          _buildTimeUnit(hours, selectedLanguage.translate('hours')),
          _buildDivider(),
          _buildTimeUnit(minutes, selectedLanguage.translate('minutes')),
          _buildDivider(),
          _buildTimeUnit(seconds, selectedLanguage.translate('seconds')),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(int value, String unit) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}