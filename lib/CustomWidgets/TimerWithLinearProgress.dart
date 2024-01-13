import 'package:flutter/material.dart';
import 'package:timer_count_down/timer_count_down.dart';

class TimerWithLinearProgress extends StatefulWidget {
  final int remainingTimeInSeconds;
  final double size; // Add size property
  final int startingSecond; // Add startingSecond property
  final int timerDuration;
  final VoidCallback? onTimerFinished;

  TimerWithLinearProgress({
    required this.remainingTimeInSeconds,
    this.size = 60.0, // Default size
    this.startingSecond = 0, // Default starting second
    this.onTimerFinished,
    this.timerDuration = 30,
  });

  @override
  _TimerWithLinearProgressState createState() =>
      _TimerWithLinearProgressState();
}

class _TimerWithLinearProgressState extends State<TimerWithLinearProgress>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Calculate initial progress value
    double initialProgress =
        widget.startingSecond / widget.remainingTimeInSeconds;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(minutes: widget.timerDuration), // Set duration to 30 minutes
      value: initialProgress, // Set initial progress
    );

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Timer finished, invoke the callback
        if (widget.onTimerFinished != null) {
          widget.onTimerFinished!();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250.0,
      decoration: BoxDecoration(
        color: Colors.grey[100],

      ),
      child: ClipRRect(
        child: SizedBox(
          width: widget.size, // Use the size property
          height: 3.0, // Use a fixed height for linear progress
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _controller.value,
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.startingSecond > widget.remainingTimeInSeconds
                      ? Color(0xFFD54D57)
                      : Color(0xFFFFEB3B),
                ),
                backgroundColor: widget.startingSecond >
                    widget.remainingTimeInSeconds
                    ? Color(0xFFD54D57).withOpacity(0.3)
                    : Color(0xFFFFEB3B).withOpacity(0.3),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

