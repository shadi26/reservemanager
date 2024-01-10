import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:reserve/Notifiers/DrawerUserName.dart';
import '../Notifiers/AuthProvider.dart';
import '../Notifiers/SelectedLanguage.dart';

class EditPhoneNumberCodeVerification {
  FirebaseAuth _auth = FirebaseAuth.instance;
  late String _verificationId;
  final FocusNode _smsFocusNode = FocusNode();

  EditPhoneNumberCodeVerification(this._auth);

  Future<String> getUserName(String uid) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (documentSnapshot.exists) {
        return documentSnapshot.get('name') ?? '';
      } else {
        return '';
      }
    } catch (e) {
      // Handle errors, e.g., Firestore query errors
      print('Error getting username: $e');
      return '';
    }
  }

  Future<User?> getUserCredentialById(String userId) async {
    try {
      // Fetch the user from Firebase Authentication using the user ID
      User? user = await _auth.currentUser;

      if (user != null && user.uid == userId) {
        // The user is currently signed in, return the user's credential
        return user;
      } else {
        // The user is not signed in or the user ID doesn't match
        // You may want to handle this case based on your requirements
        return null;
      }
    } catch (e) {
      // Handle exceptions if any
      print('Error fetching user credential: $e');
      return null;
    }
  }


  Future<void> verifySmsCode(String verificationId, String smsCode, String phoneNumber, BuildContext context, Function(String,String,String) onPhoneVerified) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    await FirebaseAuth.instance.currentUser!.updatePhoneNumber(credential);
    await _auth.signInWithCredential(PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode));

    try {
      UserCredential authResult = await _auth.signInWithCredential(credential);
      User? user = authResult.user;


      if (user != null) {
        // The user is signed in, and you can access the UID
        String uid = user.uid;
        // Check if the user already exists in the database
        bool userExists = await doesUserExist(uid);
        if (!userExists) {
          Navigator.pop(context); // Dismiss the modal bottom sheet
          _showMessage(context, 'Verification successful!');

          // Call the onPhoneVerified callback with the new phone number
          onPhoneVerified(phoneNumber,verificationId,smsCode);
        } else {
          // User already exists, handle accordingly (optional)
          print('User with UID $uid already exists in the database');
          // set the authentication provider to true
          Provider.of<MyAuthProvider>(context, listen: false).setAuthenticated(true);
          // Retrieve and set the username to UserNameProvider
          String username = await getUserName(uid);
          Provider.of<UserNameProvider>(context, listen: false).setUserName(username);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('This phone number already exists',
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
              duration: Duration(seconds: 2),),
          );
          onPhoneVerified(phoneNumber,verificationId,smsCode);
          // Close all pages until you reach the root page
          Navigator.popUntil(context, (route) => route.isFirst);
          _showMessage(context, 'Verification successful!',);
        }
      }
    } on FirebaseAuthException catch (e) {
      _showMessage(context, 'Failed to verify SMS code: ${e.message}');
    }
  }


  Future<bool> doesUserExist(String uid) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

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
      SnackBar(content: Text(message,
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

        backgroundColor: message == 'Verification successful!'? Colors.green[400]!
            :Colors.red[400]!,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void showVerificationBottomSheet(
      BuildContext context, String verificationId, String phoneNumber, Function(String,String,String) onPhoneVerified) {
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
                  padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  child: Container(
                    width: double.infinity,
                    child: Directionality(
                      textDirection: selectedLanguage.selectedLanguage == 'English'
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
                        await verifySmsCode(
                            verificationId, _smsController.text, phoneNumber, context,onPhoneVerified);
                        // If successful, navigate away or close the modal
                      } catch (e) {
                        // Show an error message if verification fails
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
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
                        await verifySmsCode(verificationId, _smsController.text, phoneNumber, context,onPhoneVerified);
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
