import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:reserve/CustomWidgets/EditPhoneNumberCodeVerification.dart';
import '../Notifiers/SelectedLanguage.dart';

class EditPhoneNumberWidget extends StatefulWidget {
  final void Function(String,String,String) onPhoneVerified;

  const EditPhoneNumberWidget({Key? key, required this.onPhoneVerified}) : super(key: key);

  @override
  _EditPhoneNumberWidgetState createState() => _EditPhoneNumberWidgetState();
}

class _EditPhoneNumberWidgetState extends State<EditPhoneNumberWidget> {
  final TextEditingController _phoneController =
  TextEditingController(text: '');
  final TextEditingController _countryCodeController =
  TextEditingController(text: '+972');
  final FocusNode _phoneFocusNode = FocusNode();
  FirebaseAuth _auth = FirebaseAuth.instance;
  late String _verificationId;
  bool _isFirstBuild = true;

  // Create an instance of CustomCodeVerificationWidget
  late EditPhoneNumberCodeVerification codeVerificationWidget;

  void _onFormSubmitted(BuildContext context) async{
    String phoneNumber = _countryCodeController.text + _phoneController.text;
    if (_phoneController.text.length == 9)
      phoneNumber = _countryCodeController.text + _phoneController.text;
    else if (_phoneController.text.length == 10)
      phoneNumber =
          _countryCodeController.text + _phoneController.text.substring(1);
    if (phoneNumber.isNotEmpty) {

      try {
        // Pass the token along with the phone number to your verification method
        verifyPhoneNumber(phoneNumber, context);
      } on PlatformException catch (e) {
        // Handle the error - maybe show a Snackbar with the error message
        final snackBar = SnackBar(content: Text('reCAPTCHA failed: ${e.message},',
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
          backgroundColor: Colors.red[400]!,
          duration: Duration(seconds: 2),);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
    else {
      // Prompt the user to enter the phone number if it's empty
      final snackBar = SnackBar(content: Text('Please enter a phone number.',
        style: TextStyle(
          fontFamily: 'Amiri',
          color: Colors.white,
          fontSize: 15,
        ),),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        backgroundColor: Colors.red[400]!,
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> verifyPhoneNumber(
      String phoneNumber, BuildContext context) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.currentUser!.updatePhoneNumber(credential);
        await _auth.signInWithCredential(credential);
        // If successful, navigate to your desired page or close the modal
      },
      verificationFailed: (FirebaseAuthException e) {
        // Show an error message
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        codeVerificationWidget.showVerificationBottomSheet(
            context, _verificationId, phoneNumber,widget.onPhoneVerified);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
        // Update your UI to let the user manually enter the SMS code
      },
    );
  }

  @override
  void initState() {
    //request focus on phone number textfield
    super.initState();
    codeVerificationWidget =
        EditPhoneNumberCodeVerification(_auth); // Initialize the widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_phoneController.text.isEmpty) {
        _phoneFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    // Dispose controllers and focus node to avoid memory leaks
    _phoneController.dispose();
    _countryCodeController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedLanguage = Provider.of<SelectedLanguage>(context);
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(10.0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFFD54D57), // Red color
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    right: 0,
                    child: IconButton(
                      onPressed: () {
                        // Navigate back when the icon is clicked
                        Navigator.pop(context);
                      },
                      icon: Image.asset(
                        'assets/icons/Xbtn.png',
                        width: 16.0, // Set the desired width of the image
                        height: 16.0, // Set the desired height of the image
                      ),
                    ),
                  ),
                  Text(
                    selectedLanguage.translate('login') ,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Amiri',
                      fontSize: 22.0,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 300.0,
              height: 180.0,
              child: Image.asset(
                'assets/images/authImg.png', // Replace with your image asset path
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(35.0, 10.0, 35.0, 10.0),
              child: Container(
                width: double.infinity,
                child: Directionality(
                  textDirection: selectedLanguage.selectedLanguage == 'English'
                      ? TextDirection.ltr
                      : TextDirection.rtl,
                  child: Text(
                    selectedLanguage.translate('enteryourphonenumber'),
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Amiri',
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30.0, 8.0, 30.0, 8.0),
              child: TextFormField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                controller: _phoneController,
                // And assign the controller here
                focusNode: _phoneFocusNode,
                decoration: InputDecoration(
                  hintText: selectedLanguage.translate('phone'),
                  hintStyle: TextStyle(
                    color: Colors.grey, // Hint text color
                    fontFamily: 'Amiri',

                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 30.0),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(
                      color: Colors.grey, // Border color when not focused
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    // Set border radius here
                    borderSide: BorderSide(
                      color: Colors.black, // Border color when focused
                    ),
                  ),
                ),

                onFieldSubmitted: (_) =>
                    _onFormSubmitted(context), // Add this line
              ),
            ),
            SizedBox(height: 12), // Spacing between the row and the button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () => _onFormSubmitted(context),
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFFD54D57), // Background color
                    ),// Modify this line
                    child: Text(
                      selectedLanguage.translate('nextbtn'),
                      style: TextStyle(
                        color: Colors.white, // Text color
                        fontFamily: 'Amiri',
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}
