import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '/Notifiers/SelectedLanguage.dart';
class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(ConnectivityResult connectivityResult) {
    if (connectivityResult == ConnectivityResult.none) {
      Get.rawSnackbar(
        messageText: Builder(
          builder: (context) {
            final selectedLanguage = Provider.of<SelectedLanguage>(context);
            return Text(
              selectedLanguage.translate("bottomnetworkmsg"),
              style: TextStyle(
                fontFamily: 'Amiri',
                color: Colors.white,
                fontSize: 14,
              ),
            );
          },
        ),
        isDismissible: false,
        duration: const Duration(days: 1),
        backgroundColor: Colors.red[400]!,
        icon: const Icon(Icons.wifi_off, color: Colors.white, size: 35,),
        margin: EdgeInsets.zero,
        snackStyle: SnackStyle.GROUNDED,
      );

      _showNoInternetDialog();
    } else {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
    }
  }

  void _showNoInternetDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Section with Icon
            Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Color(0xFFD54D57),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning,
                    color: Colors.white,
                    size: 32.0,
                  ),
                  SizedBox(width: 8.0),
                  Builder(
                    builder: (context) {
                      final selectedLanguage = Provider.of<SelectedLanguage>(context);
                      return Text(
                        selectedLanguage.translate("nointernetdialogtitle"),
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          color: Colors.white,
                          fontSize: 20.0,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Bottom Section with Text and Button
            Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Builder(
                    builder: (context) {
                      final selectedLanguage = Provider.of<SelectedLanguage>(context);
                      return Text(
                        selectedLanguage.translate("nointernetdialogmsg"),
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 18.0,
                          color: Colors.black, // Add this line to set the text color
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFFD54D57),
                    ),
                    onPressed: () async {
                      // Check if the internet is back before allowing navigation
                      if (await _isInternetAvailable()) {
                        Get.back(); // Close the dialog
                        _retryAction(); // Trigger the retry action
                      } else {
                        print('Still no internet. Action blocked.');
                      }
                    },
                    child: Builder(
                      builder: (context) {
                        final selectedLanguage = Provider.of<SelectedLanguage>(context);
                        return Text(
                          selectedLanguage.translate("nointernetdialogbutton"),
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            color: Colors.white, // Set the text color to black
                            fontSize: 18.0,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false, // Set to true to allow dismissal by clicking outside
    );
  }


  // Helper function to check internet connectivity
  Future<bool> _isInternetAvailable() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Callback for retry action (customize this for your use case)
  void _retryAction() {
    final currentRoute = Get.currentRoute;
    if (currentRoute != null) {
      Get.offAllNamed(currentRoute);
    }
  }
}
