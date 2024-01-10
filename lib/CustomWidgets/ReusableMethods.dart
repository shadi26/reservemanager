import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ReusableMethods {
  //static function to determine Card Status
  static String determineCardStatus(List<dynamic> dailyOpeningTimes) {
    // Get the current time as DateTime
    DateTime currentTime = DateTime.now();
    if (dailyOpeningTimes.length == 2) {
      String startTime = dailyOpeningTimes[0];
      String endTime = dailyOpeningTimes[1];

      // Create DateTime objects for today with the provided time
      DateTime todayStartTime = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        int.parse(startTime.split(':')[0]),
        int.parse(startTime.split(':')[1]),
      );

      DateTime todayEndTime = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        int.parse(endTime.split(':')[0]),
        int.parse(endTime.split(':')[1]),
      );


      if (currentTime.isAfter(todayStartTime) && currentTime.isBefore(todayEndTime)) {
        return 'open';
      } else {
        return 'closed';
      }
    } else {
      return 'closed'; // If the array does not have both opening and closing times, consider it closed
    }
  }


  static void showEnlargeView(BuildContext context, List<dynamic> imageUrls, int initialIndex) {
    final Size screenSize = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Dialog(
            insetPadding: EdgeInsets.all(0),
            backgroundColor: Colors.transparent,
            child: Container(
              width: screenSize.width - 0.1 * screenSize.width,
              height: screenSize.height - 0.45 * screenSize.height,
              child: PageView.builder(
                itemCount: imageUrls.length,
                controller: PageController(
                  initialPage: initialIndex,
                  viewportFraction: 1.0,
                ),
                itemBuilder: (context, index) {
                  return CachedNetworkImage(
                    imageUrl: imageUrls[index],
                    fit: BoxFit.fill,
                    placeholder: (context, url) {
                      // Display a placeholder while the image is loading
                      return Center(child: CircularProgressIndicator());
                    },
                    errorWidget: (context, url, error) {
                      // Display an error placeholder or handle the error as needed
                      print('Error loading image: $error');
                      return Container(
                        color: Colors.red,
                        child: Center(
                          child: Icon(
                            Icons.error,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
