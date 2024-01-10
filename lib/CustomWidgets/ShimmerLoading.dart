
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reserve/CustomWidgets/RPSCustomPainter.dart';
import 'package:shimmer/shimmer.dart';

import '../Notifiers/SelectedLanguage.dart';

class ShimmerLoading {
  static Widget shimmerLoadingContent(BuildContext context) {
    final lightGreyColor = Colors.grey[300]!;

    return Container(
      margin: EdgeInsets.all(10.0),
      padding: EdgeInsets.all(10.0),
      height: 451.0,
      decoration: BoxDecoration(
        color:Colors.grey[100]! ,
        border: Border.all(
          color: Colors.grey.withOpacity(0.6),
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 5), // Adjust the offset if needed
          ),

        ],
      ),
      child: Column(
        children: [
        Shimmer.fromColors(
        baseColor: lightGreyColor,
        highlightColor: Colors.grey[100]!,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(

            width: 250.0,
            height: 40.0,
            decoration: BoxDecoration(
              color:Colors.grey[100]! ,
              border: Border.all(
                color: Colors.grey.withOpacity(0.6),
                width: 1.2,
              ),
              borderRadius: BorderRadius.circular(10.0),

            ),
          ),
        ),
        ),
          Shimmer.fromColors(
            baseColor: lightGreyColor,
            highlightColor: Colors.grey[100]!,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Container(
                    width: 170.0,
                    height: 170.0,
                    decoration: BoxDecoration(
                      color:Colors.grey[100]! ,
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.6),
                        width: 1.2,
                      ),
                      borderRadius: BorderRadius.circular(10.0),

                    ),
                  ),
                  SizedBox(width: 10.0),
                  Container(
                    width: 170.0,
                    height: 170.0,
                    decoration: BoxDecoration(
                      color:Colors.grey[100]! ,
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.6),
                        width: 1.2,
                      ),
                      borderRadius: BorderRadius.circular(10.0),

                    ),
                  ),
                  // Add more shimmering containers as needed
                ],
              ),
            ),
          ),
          Shimmer.fromColors(
            baseColor: lightGreyColor,
            highlightColor: Colors.grey[100]!,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Container(
                    width: 170.0,
                    height: 170.0,
                    decoration: BoxDecoration(
                      color:Colors.grey[100]! ,
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.6),
                        width: 1.2,
                      ),
                      borderRadius: BorderRadius.circular(10.0),

                    ),
                  ),
                  SizedBox(width: 10.0),
                  Container(
                    width: 170.0,
                    height: 170.0,
                      decoration: BoxDecoration(
                        color:Colors.grey[100]! ,
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.6),
                          width: 1.2,
                        ),
                        borderRadius: BorderRadius.circular(10.0),

                      ),
                  ),
                  // Add more shimmering containers as needed
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  static Widget shimmerLoadingCarousel(BuildContext context) {
    final lightGreyColor = Colors.grey[300]!;

    return Shimmer.fromColors(
      baseColor: lightGreyColor,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: 200.0, // Adjust the height according to your needs
        margin: EdgeInsets.symmetric(vertical: 15.0),
        color: lightGreyColor,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 5, // Number of shimmer items in the carousel
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 120.0,
                height: 150.0,
                color: Colors.grey[300]!,
              ),
            );
          },
        ),
      ),
    );
  }

  static Widget shimmerLoadingTitles(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        child: ListTile(
          dense: true,
          contentPadding: EdgeInsets.all(7),
          leading: CircleAvatar(
            backgroundColor: Colors.grey[300],
            radius: 20,
          ),
          title: Container(
            height: 10,
            color: Colors.grey[300],
          ),
        ),
      ),
    );
  }
  static Widget textShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Text(
        '...',
        style: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  static Widget circleImageLoading(BuildContext context,double rad) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: CircleAvatar(
        radius: rad,
        backgroundColor: Colors.white,
      ),
    );
  }
  static Widget buildShimmerLoadingListTile(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey,
          radius: 30,
        ),
        title: Container(
          height: 20,
          width: 150,
          color: Colors.grey,
        ),
        subtitle: Container(
          height: 20,
          width: 200,
          color: Colors.grey,
        ),
        trailing: Container(
          width: 30,
          height: 30,
          color: Colors.grey,
        ),
      ),
    );
  }

  static Widget CircularImageSliderShimmer() {
    return
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 120.0, // Adjust the height as needed
          decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
          color: Colors.grey.withOpacity(0.6),
            width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 10,
                offset: Offset(0, 5), // Adjust the offset if needed
              ),

            ],
            borderRadius: BorderRadius.circular(25),
          ),

          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Column(
                  children: [
                    Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 75.0, // Set a fixed width for the circular image
                        height: 65.0, // Make the height the same as the width
                        margin: EdgeInsets.symmetric(horizontal: 18.0),
                        decoration: BoxDecoration(
                          color:Colors.grey[100]! ,
                          shape: BoxShape.circle, // Use BoxShape.circle for circular container

                        ),
                      ),
                    ),
                    SizedBox(height: 8.0,),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 12,
                        width: 30,
                        decoration: BoxDecoration(
                          color:Colors.grey[100]! ,
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.6),
                            width: 1.2,
                          ),
                          borderRadius: BorderRadius.circular(10.0),

                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 10,),
                Column(
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 70.0, // Set a fixed width for the circular image
                        height: 65.0, // Make the height the same as the width
                        margin: EdgeInsets.symmetric(horizontal: 18.0),
                        decoration: BoxDecoration(
                          color:Colors.grey[100]! ,
                          shape: BoxShape.circle, // Use BoxShape.circle for circular container

                        ),
                      ),
                    ),
                    SizedBox(height: 8.0,),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 12,
                        width: 30,
                        decoration: BoxDecoration(
                          color:Colors.grey[100]! ,
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.6),
                            width: 1.2,
                          ),
                          borderRadius: BorderRadius.circular(10.0),

                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 10,),
                Column(
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 80.0, // Set a fixed width for the circular image
                        height: 65.0, // Make the height the same as the width
                        margin: EdgeInsets.symmetric(horizontal: 18.0),
                        decoration: BoxDecoration(
                          color:Colors.grey[100]! ,
                          shape: BoxShape.circle, // Use BoxShape.circle for circular container

                        ),
                      ),
                    ),
                    SizedBox(height: 8.0,),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 12,
                        width: 30,
                        decoration: BoxDecoration(

                          color:Colors.grey[100]! ,
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.6),
                            width: 1.2,
                          ),
                          borderRadius: BorderRadius.circular(10.0),

                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
  }
  static Widget CurrentReservationShimmer(BuildContext context) {
    final lightGreyColor = Colors.grey[300]!;
    final darkGreyColor = Colors.grey[100]!;
    final selectedLanguage = Provider.of<SelectedLanguage>(context);
    return Container(
      margin: EdgeInsets.all(10.0),
      padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
      width: double.infinity,
      height: 300.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: darkGreyColor,
        boxShadow: [
          BoxShadow(
            color: Colors.transparent,
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Text containers on the left side
          Positioned(
            top: 60.0, // Adjust the position of the text containers
            left: 0.0,
            right: 0.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Other Containers
                Shimmer.fromColors(
                  baseColor: lightGreyColor,
                  highlightColor: darkGreyColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 200,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: darkGreyColor,
                        ),
                        margin: EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 5.0),
                      ),
                      Container(
                        width: 200,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: darkGreyColor,
                        ),
                        margin: EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 5.0),
                      ),
                      Container(
                        width: 200,
                        height: 40,
                        margin: EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: darkGreyColor,
                        ),
                      ),
                      Container(
                        width: 200,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: darkGreyColor,
                        ),
                        margin: EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 5.0),

                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Top Container with radius
          Shimmer.fromColors(
            baseColor: lightGreyColor,
            highlightColor: darkGreyColor,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
                color: Color(0xFFD54D57),
              ),
              height: 50.0,
              margin: EdgeInsets.symmetric(vertical: 10.0),
            ),
          ),

          // Right side with the circular image
          Positioned(
            top: 80.0, // Adjust the position of the circular image
            right: selectedLanguage.selectedLanguage == 'English'? 10.0:220.0,

            child: Shimmer.fromColors(
              baseColor: lightGreyColor,
              highlightColor: darkGreyColor,
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
                    width: 3.0,
                  ),
                  gradient: LinearGradient(
                    colors: [Color(0xFFD54D57), darkGreyColor],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: ClipOval(
                  // Add your image here

                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  static Widget buildProfilePageShimmer(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          size: const Size(double.maxFinite, 240),
          painter: RPSCustomPainter(),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 68.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(0xFFCCC2C3),
                    width: 5.0,
                  ),
                ),
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.white, // Placeholder color
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 168, left: 130.0),
            child: IconButton(
              onPressed: () {}, // Placeholder onPressed function
              icon: Image.asset(
                'assets/icons/cameraicon.png',
                width: 50,
                height: 50,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 250.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Text(
                '.....',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 310.0),
          child: Container(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0),
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 0,
                                    blurRadius: 1,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              height: 60,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 10, 8.0, 8.0),
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 0,
                                    blurRadius: 1,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              height: 60,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 10, 8.0, 8.0),
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 0,
                                    blurRadius: 1,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              height: 60,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 10, 8.0, 8.0),
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              decoration: BoxDecoration(

                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 0,
                                    blurRadius: 1,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              height: 60,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
 static Widget AppbarShimmer(BuildContext context) {
    return Container(
      height: kToolbarHeight+10,
      color: Colors.transparent,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0,top: 15.0),
              child: Icon(
                Icons.menu,
                color: Colors.white,
                size: 24.0,
              ),
            ),

            Expanded(
              child: Center(
                child: Text(
                  ".......",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

}

