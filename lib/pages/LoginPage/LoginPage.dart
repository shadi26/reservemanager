import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:reserve/Notifiers/DrawerUserName.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Notifiers/UserIdProvider.dart';
import '../../../Notifiers/AuthProvider.dart';



class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  late final authProvider;




  Future<Map<String, dynamic>> fetchUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
    }
    return {};
  }

  Future<UserCredential> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in with the Google credential
        final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

        // Get the user ID
        final String userId = userCredential.user?.uid ?? '';

        // Save the user ID in the provider
        Provider.of<UserIdProvider>(context, listen: false).setUserId(userId);
        Provider.of<MyAuthProvider>(context, listen: false).setAuthenticated(true);

        // Pop back to the first page
        Navigator.of(context).popUntil((route) => route.isFirst);

        return userCredential;
      } else {
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      }
    } catch (e) {
      // Handle any errors that occur during the sign-in process
      print('Error signing in with Google: $e');
      throw FirebaseAuthException(
        code: 'ERROR_GOOGLE_SIGN_IN_FAILED',
        message: 'Google sign in failed',
      );
    }
  }


  Future<UserCredential> signInWithEmailPassword(BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Update the user ID in the provider
      if (userCredential.user != null) {
        Provider.of<UserIdProvider>(context, listen: false).setUserId(userCredential.user!.uid);
        Provider.of<MyAuthProvider>(context, listen: false).setAuthenticated(true);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle the error, e.g., user not found, wrong password
      throw FirebaseAuthException(
        code: e.code,
        message: e.message,
      );
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/images/background.jpg'),
                          fit: BoxFit.fill)),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        left: 30,
                        width: 80,
                        height: 200,
                        child: FadeInUp(
                            duration: Duration(seconds: 1),
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/light-1.png'))),
                            )),
                      ),
                      Positioned(
                        left: 140,
                        width: 80,
                        height: 150,
                        child: FadeInUp(
                            duration: Duration(milliseconds: 1200),
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/light-2.png'))),
                            )),
                      ),
                      Positioned(
                        right: 40,
                        top: 40,
                        width: 80,
                        height: 150,
                        child: FadeInUp(
                            duration: Duration(milliseconds: 1300),
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/clock.png'))),
                            )),
                      ),
                      Positioned(
                        child: FadeInUp(
                            duration: Duration(milliseconds: 1600),
                            child: Container(
                              margin: EdgeInsets.only(top: 50),
                              child: Center(
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Column(
                    children: <Widget>[
                      FadeInUp(
                          duration: Duration(milliseconds: 1800),
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Color(0xFFD54D57)),
                                boxShadow: [
                                  BoxShadow(
                                      color: Color(0xFFD54D57),
                                      blurRadius: 20.0,
                                      offset: Offset(0, 10))
                                ]),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Color(0xFFD54D57)))),
                                  child: TextField(
                                    controller: emailController,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Email or Phone number",
                                        hintStyle:
                                        TextStyle(color: Colors.grey[700])),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(8.0),
                                  child: TextField(
                                    controller: passwordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Password",
                                        hintStyle:
                                        TextStyle(color: Colors.grey[700])),
                                  ),
                                )
                              ],
                            ),
                          )),
                      SizedBox(
                        height: 30,
                      ),

                      // Row for Facebook, Google, and Phone Login Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[

                          // Google Login Button
                          FadeInUp(
                            duration: Duration(milliseconds: 2200),
                            child: IconButton(
                              icon: Icon(
                                Icons.g_translate,
                                // Use the "Google" icon from flutter_icons,
                                color: Colors.red, // Change the color as needed
                                size: 40.0,
                              ),
                              onPressed: () async{
                                // Add your Google login logic here
                                try {
                                  await signInWithGoogle(context);
                                  // Navigate to the next screen if successful
                                } catch (e) {
                                  // Handle error (e.g., show a message)
                                }
                              },
                            ),
                          ),

                        ],
                      ),

                      // Modify the "Login" button to use signInWithEmailPassword
                      FadeInUp(
                        duration: Duration(milliseconds: 1900),
                        child: GestureDetector(
                          onTap: () async {
                            try {
                              // Call signInWithEmailPassword and wait for the result
                              UserCredential userCredential = await signInWithEmailPassword(context);

                              // Extracting the user's email as the username
                              String username = userCredential.user?.email ?? '';

                              // Fetch the user's name from Firestore and update UserNameProvider
                              if (userCredential.user != null) {
                                Map<String, dynamic> userData = await fetchUserData();

                                // Convert userData to JSON string
                                String userDataJson = jsonEncode(userData);

                                // Save the JSON string in SharedPreferences
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                await prefs.setString('userData', userDataJson);

                                // Set isAuthenticated to true in MyAuthProvider
                                Provider.of<MyAuthProvider>(context, listen: false).setAuthenticated(true);
                              }

                              // Proceed with your logic after successful sign-in
                              // For example, navigate to another screen
                            } catch (e) {
                              // Handle error (e.g., show a message)
                            }
                          },

                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color(0xFFD54D57),
                            ),
                            child: Center(
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 70,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}