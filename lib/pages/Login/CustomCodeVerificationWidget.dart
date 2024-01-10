import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:reserve/Notifiers/DrawerUserName.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Notifiers/AuthProvider.dart';
import '../../Notifiers/SelectedLanguage.dart';
import '../../Notifiers/UserIdProvider.dart';
import 'CustomNameEntryWidget.dart';

class CustomCodeVerificationWidget {
  bool _isLoading = false; // Step 1: Add _isLoading variable
  FirebaseAuth _auth = FirebaseAuth.instance;
  late String _verificationId;
  final FocusNode _smsFocusNode = FocusNode();

  CustomCodeVerificationWidget(this._auth);
  // Save defaultLanguage to SharedPreferences
  Future<void> saveDefaultLanguage(String defaultLanguage) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('defaultLanguage', defaultLanguage);
  }

  Future<Map<String, dynamic>> getUserData(String uid) async {
    try {
      DocumentSnapshot documentSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (documentSnapshot.exists) {
        String name = documentSnapshot.get('name') ?? '';
        String defaultLanguage = documentSnapshot.get('defaultLanguage') ?? '';

        return {'name': name, 'defaultLanguage': defaultLanguage};
      } else {
        return {'name': '', 'defaultLanguage': ''};
      }
    } catch (e) {
      // Handle errors, e.g., Firestore query errors
      print('Error getting user data: $e');
      return {'name': '', 'defaultLanguage': ''};
    }
  }

  Future<void> verifySmsCode(String verificationId, String smsCode,
      String phoneNumber, BuildContext context) async {
    _isLoading =
        true; // Step 1: Set loading state to true before starting verification

    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    try {
      UserCredential authResult = await _auth.signInWithCredential(credential);
      User? user = authResult.user;

      if (user != null) {
        // The user is signed in, and you can access the UID
        String uid = user.uid;

        AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        );

        // Reauthenticate the user
        await user.reauthenticateWithCredential(credential);

        // Now update the phone number
        await user.updatePhoneNumber(PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        ));

        // Update the user ID in the provider
        Provider.of<UserIdProvider>(context, listen: false).setUserId(uid);

        // Check if the user already exists in the database
        bool userExists = await doesUserExist(uid);

        if (!userExists) {
          Navigator.pop(context); // Dismiss the modal bottom sheet
          _showMessage(context, 'Verification successful!');
          CustomNameEntryWidget.showNameEntryDialog(
              context, phoneNumber, uid); // Show name entry dialog
        } else {
          // User already exists, handle accordingly (optional)
          print('User with UID $uid already exists in the database');
          // set the authentication provider to true
          Provider.of<MyAuthProvider>(context, listen: false)
              .setAuthenticated(true);
          // Retrieve user data including name and defaultLanguage
          Map<String, dynamic> userData = await getUserData(uid);

          // Access the name and defaultLanguage
          String username = userData['name'];
          String defaultLanguage = userData['defaultLanguage'];

          // Set the username to UserNameProvider
          Provider.of<UserNameProvider>(context, listen: false)
              .setUserName(username);

          // Set the defaultLanguage to your provider if needed
          Provider.of<SelectedLanguage>(context, listen: false)
              .setLanguage(defaultLanguage);

          saveDefaultLanguage(defaultLanguage);

          // Close all pages until you reach the root page
          Navigator.popUntil(context, (route) => route.isFirst);
          _showMessage(context, 'Verification successful!');
        }
      }
    } on FirebaseAuthException catch (e) {
      _isLoading =
          false; // Step 1: Set loading state to false after verification fails
      _showMessage(context, 'Failed to verify SMS code: ${e.message}');
    }
  }

  Future<bool> doesUserExist(String uid) async {
    try {
      DocumentSnapshot documentSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      return documentSnapshot.exists;
    } catch (e) {
      // Handle errors, e.g., Firestore query errors
      print('Error checking user existence: $e');
      return false;
    }
  }

  Future<void> resendCode(String phoneNumber, BuildContext context) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        _showMessage(context, 'Verification failed: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
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
        backgroundColor: message == 'Verification successful!'
            ? Colors.green[400]!
            : Colors.red[400]!,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void showVerificationBottomSheet(
      BuildContext context, String verificationId, String phoneNumber) {
    final TextEditingController _smsController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext bc) {
        final selectedLanguage = Provider.of<SelectedLanguage>(context);
        // Add a post-frame callback to focus the text field after the frame has been rendered
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          FocusScope.of(context).requestFocus(_smsFocusNode);
        });

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
                    color: Color(0xFFD54D57),
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
                          icon: Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            // Navigate back when the arrow is clicked
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Text(
                        selectedLanguage.translate('authenticationcode'),
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Amiri',
                          fontSize: 20.0,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15.0),
                Container(
                  width: 300.0,
                  height: 180.0,
                  child: Image.asset(
                    'assets/images/authImg1.png',
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(35.0, 10.0, 35.0, 10.0),
                  child: Container(
                    width: double.infinity,
                    child: Directionality(
                      textDirection:
                          selectedLanguage.selectedLanguage == 'English'
                              ? TextDirection.ltr
                              : TextDirection.rtl,
                      child: Text(
                        selectedLanguage.translate('enterauthenticationcode'),
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
                  padding: const EdgeInsets.fromLTRB(35.0, 10.0, 35.0, 10.0),
                  child: TextField(
                    focusNode: _smsFocusNode,
                    keyboardType: TextInputType.number,
                    controller: _smsController,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '******',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontFamily: 'Amiri',
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 30.0),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    onSubmitted: (String value) async {
                      try {
                        await verifySmsCode(verificationId, _smsController.text,
                            phoneNumber, context);
                        // If successful, navigate away or close the modal
                      } catch (e) {
                        // Show an error message if verification fails
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 0.0),
                  child: InkWell(
                    onTap: () => resendCode(phoneNumber, context),
                    child: Text(
                      selectedLanguage.translate('resendcode'),
                      style: TextStyle(
                        color: Colors.blue,
                        fontFamily: 'Amiri',
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFFD54D57),
                    ),
                    child: Text(
                      selectedLanguage.translate('okbtn'),
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Amiri',
                        fontSize: 18.0,
                      ),
                    ),
                    onPressed: () async {
                      try {
                        await verifySmsCode(verificationId, _smsController.text,
                            phoneNumber, context);
                        // If successful, navigate away or close the modal
                      } catch (e) {
                        // Show an error message if verification fails
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
