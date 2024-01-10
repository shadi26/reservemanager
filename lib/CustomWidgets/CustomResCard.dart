import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reserve/Notifiers/ReservationDoneNotifier.dart';
import '../../CustomWidgets/TimerWithLinearProgress.dart';
import '../Notifiers/SelectedLanguage.dart';
import 'CountdownTimer.dart';
import 'CustomConfirmationDialog.dart';


class ReservationModel with ChangeNotifier {
  int remainingTimeInSeconds =
      1800; // Initial value, you can replace it with your logic

  void updateRemainingTime(int newTime) {
    remainingTimeInSeconds = newTime;
    notifyListeners();
  }
}

class CustomResCard extends StatelessWidget {
  final String reservationTime;
  final String reservationNumber;
  final String venueName;
  final String paymentType;
  final String imageUrl;
  final String reservationType;
  final String reservationResult;
  final int timeRmainingInSeconds;
  final Duration countdownDuration;
  final String timeBooked;
  final String rid;
  final String totalAmount;
  final Timestamp reservationTimeStamp;

  const CustomResCard({
    Key? key,
    required this.reservationTime,
    required this.reservationNumber,
    required this.venueName,
    required this.paymentType,
    required this.imageUrl,
    required this.reservationType,
    required this.reservationResult,
    required this.timeRmainingInSeconds,
    required this.countdownDuration, // Add this line
    required this.timeBooked,
    required this.rid,
    required this.totalAmount,
    required this.reservationTimeStamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ReservationModel(),
      child: CustomResCardWidget(
        key: PageStorageKey<String>('currentTab_${rid}'), // Use PageStorageKey
        reservationTime: reservationTime,
        reservationNumber: reservationNumber,
        venueName: venueName,
        paymentType: paymentType,
        imageUrl: imageUrl,
        reservationType: reservationType,
        reservationResult: reservationResult,
        timeRmainingInSeconds: timeRmainingInSeconds,
        countdownDuration: countdownDuration,
        timeBooked: timeBooked,
        rid: rid,
        totalAmount: totalAmount,
        reservationTimeStamp: reservationTimeStamp,
      ),
    );
  }
}

class CustomResCardWidget extends StatefulWidget {
  final String reservationTime;
  final String reservationNumber;
  final String venueName;
  final String paymentType;
  final String imageUrl;
  final String reservationType;
  final String reservationResult;
  final int timeRmainingInSeconds;
  final Duration countdownDuration;
  final String timeBooked;
  final String rid;
  final String totalAmount;
  final Timestamp reservationTimeStamp;

  const CustomResCardWidget({
    Key? key,
    required this.reservationTime,
    required this.reservationNumber,
    required this.venueName,
    required this.paymentType,
    required this.imageUrl,
    required this.reservationType,
    required this.reservationResult,
    required this.timeRmainingInSeconds,
    required this.countdownDuration, // Add this line
    required this.timeBooked,
    required this.rid,
    required this.totalAmount,
    required this.reservationTimeStamp,

  }) : super(key: key);

  @override
  _CustomResCardState createState() => _CustomResCardState();
}

class _CustomResCardState extends State<CustomResCardWidget> {
  late String resResult;
  bool _isDataLoaded = false;
  late Duration timeDifference;
  late int LinearProgressStartTime;



  @override
  void initState() {
    //Calculations for the countdowntimer
    // Combine date and time to create a DateTime object
    String formattedDateString = widget.timeBooked;

    DateTime reservationDateTime = DateTime.parse(
      formattedDateString.replaceAllMapped(
        RegExp(r'(\d{2})-(\d{2})-(\d{4}) (\d{2}:\d{2})'),
            (match) => '${match[3]}-${match[2]}-${match[1]} ${match[4]}',
      ),
    );

    // Get the current time
    DateTime now = DateTime.now();

    // Calculate the time difference
    timeDifference = reservationDateTime.difference(now);

    //Calculations for the linearTimer
    // Get the current time
    Timestamp currentTime = Timestamp.now();

    // Get the reservation timestamp from the document
    Timestamp reservationTimeStamp = widget.reservationTimeStamp;

    // Calculate the difference in seconds between the current time and the reservation timestamp
    LinearProgressStartTime= currentTime.seconds - reservationTimeStamp.seconds;


    super.initState();
    resResult = widget.reservationResult;
  }


  Future<void> deleteReservation(
      String documentId,
      ReservationModel model,
      ReservationDoneNotifier numberProvider,
      BuildContext context,
      ) async {
    try {
      await FirebaseFirestore.instance
          .collection('Reservations')
          .doc(documentId)
          .delete();

      // Show a Snackbar with the success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Reservation deleted successfully',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Amiri',
              color: Colors.white,
              fontSize: 15,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: Colors.green[400]!,
          duration: Duration(seconds: 2),
        ),
      );

      // Update the remaining time in the provider
      model.updateRemainingTime(widget.timeRmainingInSeconds);

      // Decrement the counter in the ReservationNumberProvider
      numberProvider.notifyReservationDone();
    } catch (error) {
      print('Error deleting reservation: $error');
    }
  }


  @override
  Widget build(BuildContext context) {

    final ReservationDoneNotifier numberProvider =
    Provider.of<ReservationDoneNotifier>(context, listen: false); // Access the existing provider without rebuilding

    // Get the selected language from the provider
    final selectedLanguage = Provider.of<SelectedLanguage>(context);
    return Consumer<ReservationModel>(
      builder: (context, model, child) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 3,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0),
                  ),
                  color: Color(0xFFD54D57),
                ),

                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0, top: 5.0),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          selectedLanguage.translate('reservationnumber') +
                              ': ${widget.reservationNumber}',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            color: Colors.white,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, top: 5.0),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          widget.reservationTime,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            color: Colors.white,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Container(
                          width: 220,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 0,
                                blurRadius: 0,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),

                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(5.0, 5.0, 8.0, 5.0),
                            child: Directionality(
                              textDirection:
                                  selectedLanguage.selectedLanguage == 'English'
                                      ? TextDirection.ltr
                                      : TextDirection.rtl,
                              child: Text(
                                selectedLanguage
                                        .translate('reservationservicename') +
                                    ': ${selectedLanguage.translate(widget.venueName.toLowerCase())}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Amiri',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Container(
                          width: 220,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 0,
                                blurRadius: 0,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(5.0, 5.0, 8.0, 5.0),
                            child: Directionality(
                              textDirection:
                                  selectedLanguage.selectedLanguage == 'English'
                                      ? TextDirection.ltr
                                      : TextDirection.rtl,
                              child: Text(
                                selectedLanguage
                                        .translate('reservationpayment') +
                                    ': ${selectedLanguage.translate('${widget.paymentType.toLowerCase()}method')}',
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Container(
                          width: 220,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 0,
                                blurRadius: 0,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding:
                            const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                            child: Directionality(
                              textDirection:
                              selectedLanguage.selectedLanguage == 'English'
                                  ? TextDirection.ltr
                                  : TextDirection.rtl,
                              child: Text(
                                selectedLanguage.translate('booked') +
                                    ': ${widget.timeBooked}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Amiri',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Container(
                          width: 220,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 0,
                                blurRadius: 0,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding:
                            const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                            child: Directionality(
                              textDirection:
                              selectedLanguage.selectedLanguage == 'English'
                                  ? TextDirection.ltr
                                  : TextDirection.rtl,
                              child: Text(
                                selectedLanguage.translate('rescardamount') +
                                    ': ${widget.totalAmount}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Amiri',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Container(
                          width: 220,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 0,
                                blurRadius: 0,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              widget.reservationType == 'current'
                                  ? Positioned.fill(
                                child: TimerWithLinearProgress(
                                  remainingTimeInSeconds: 1800,
                                  startingSecond: LinearProgressStartTime,
                                  size: 40.0,
                                  timerDuration: 5,
                                  onTimerFinished: () {
                                    setState(() {
                                      // Update the text or take any action
                                      resResult = 'Cancelled';
                                    });
                                  },
                                ),
                              )
                                  : SizedBox(width: 0,),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(5.0, 5.0, 8.0, 5.0),
                                child: Directionality(
                                  textDirection: selectedLanguage.selectedLanguage == 'English'
                                      ? TextDirection.ltr
                                      : TextDirection.rtl,
                                  child: Text(
                                    selectedLanguage.translate('reservatiostatus') +
                                        ': ${selectedLanguage.translate(resResult)}',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'Amiri',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),



                    ],
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 10.0),
                      child: Container(
                        width: 140.0,
                        height: 140.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.transparent,
                            // Set border color to transparent
                            width: 3.0,
                          ),
                          gradient: LinearGradient(
                            colors: [Color(0xFFD54D57), Colors.white],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            widget.imageUrl,
                            // Assuming uint8List is your Uint8List variable
                            width: 140.0,
                            height: 140.0,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              //
              if (widget.reservationType == 'current')
                Column(
                  children: [
                    Padding(
                      padding:
                      const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      child: Container(
                        alignment: AlignmentDirectional.bottomEnd,
                        child: ElevatedButton(
                          onPressed: () {
                            ConfirmationDialog.show(
                              context: context,
                              title: selectedLanguage.translate('cancelcurrentres'),
                              content: selectedLanguage.translate('cancelcurrentresmsg'),
                              confirmButtonText: selectedLanguage.translate('yesbtn'),
                              cancelButtonText: selectedLanguage.translate('nobtn'),
                              onConfirm: () {
                                setState(() {
                                  deleteReservation(
                                      widget.rid, model, numberProvider,context);
                                });
                              },
                            );
                          },
                          child: Text(
                            selectedLanguage.translate('reservationcancel'),
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Amiri',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xFFD54D57),
                            onPrimary: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Improved design for the timeBooked text

                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(50.0, 10.0, 50.0, 10.0),
                      child: CountdownTimer(
                        startTime: timeDifference,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
