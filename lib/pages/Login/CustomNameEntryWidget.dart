import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Notifiers/AuthProvider.dart';
import '../../Notifiers/DrawerUserName.dart';
import '../../Notifiers/SelectedLanguage.dart';


class CustomNameEntryWidget {
  static void showNameEntryDialog(
      BuildContext context,
      String phoneNumber,
      String uid,
      ) {
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _emailController = TextEditingController();

    void submitUserData() async {
      String userName = _nameController.text;
      String email = _emailController.text;
      String phone = phoneNumber;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': userName,
        'email': email,
        'phone': phone,
        'defaultLanguage': 'Arabic',
      });

      Provider.of<UserNameProvider>(context, listen: false).setUserName(userName);
      Provider.of<MyAuthProvider>(context, listen: false).setAuthenticated(true);

      Navigator.popUntil(context, (route) => route.isFirst);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final selectedLanguage = Provider.of<SelectedLanguage>(context);
        return AlertDialog(
          content: Container(
            width: 350.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 50.0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFFD54D57),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      topRight: Radius.circular(15.0),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        right: 0,
                        child: IconButton(
                          icon: Image.asset(
                            'assets/icons/Xbtn.png',
                            width: 14, // Set the desired width
                            height: 14, // Set the desired height
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Text(
                        selectedLanguage.translate('enteryourinfo'),
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Amiri',
                          fontSize: 20.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 10.0),
                  child: TextField(
                    controller: _nameController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: selectedLanguage.translate('yourname'),
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
                    onSubmitted: (_) => submitUserData(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30.0, 8.0, 30.0, 20.0),
                  child: TextField(
                    controller: _emailController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: selectedLanguage.translate('youremail'),
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
                    keyboardType: TextInputType.emailAddress,
                    onSubmitted: (_) => submitUserData(),
                  ),
                ),
              ],
            ),
          ),
          contentPadding: EdgeInsets.zero,
          actions: <Widget>[
            Center(
              child: ElevatedButton(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    selectedLanguage.translate('savebtn'),
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Amiri',
                      fontSize: 20.0,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFFD54D57),
                ),
                onPressed: submitUserData,
              ),
            ),
          ],
        );
      },
    );
  }
}
