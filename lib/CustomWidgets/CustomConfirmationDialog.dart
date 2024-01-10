import 'package:flutter/material.dart';

class ConfirmationDialog {
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmButtonText,
    required String cancelButtonText,
    required VoidCallback onConfirm,
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
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
                      Text(
                        title,
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
                  padding: const EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 15.0),
                  child: Container(
                    child: Text(
                      content,
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Amiri',
                        fontSize: 22.0,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Close the dialog without confirming
                          Navigator.pop(context);
                        },
                        child: Text(
                          cancelButtonText,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Amiri',
                            fontSize: 18.0,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFFD54D57),
                        ),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Perform the confirm action
                          onConfirm();
                          Navigator.pop(context);
                        },
                        child: Text(
                          confirmButtonText,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Amiri',
                            fontSize: 18.0,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFFD54D57),

                        ),

                      ),
                      
                    ],
                  ),
                )
              ],
            ),
          ),
          contentPadding: EdgeInsets.zero, // Adjust the contentPadding
        );
      },
    );
  }
}
