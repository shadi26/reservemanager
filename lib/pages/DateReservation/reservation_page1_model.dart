import '../../CustomWidgets/CustomModelCalendar.dart';
import '../../CustomWidgets/CustomUtill.dart';
import 'DateReservation.dart' show ReservationPage1Widget;
import 'package:flutter/material.dart';

class ReservationPage1Model extends FlutterFlowModel<ReservationPage1Widget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // State field(s) for Calendar widget.
  DateTimeRange? calendarSelectedDay;

  /// Initialization and disposal methods.

  void initState(BuildContext context) {
    calendarSelectedDay = DateTimeRange(
      start: DateTime.now().startOfDay,
      end: DateTime.now().endOfDay,
    );
  }

  void dispose() {
    unfocusNode.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
