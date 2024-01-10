import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Center(
          child: Container(
            color: Color(0xFFD54D57), // White background
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  child: Lottie.asset(
                    'assets/bigcloud.json', // Replace with the path to your cloud Lottie JSON file
                    width: 60, // Replace with your desired width
                    height: 60, // Replace with your desired height
                    repeat: true, // Set to true if you want the cloud animation to loop
                    frameRate: FrameRate.max,
                  ),
                  top: 0, // Adjust the top position as needed
                  left: 60, // Adjust the left position as needed
                  bottom: -650,
                ),
                Positioned(
                  child: Lottie.asset(
                    'assets/bigcloud.json', // Replace with the path to your cloud Lottie JSON file
                    width: 130, // Replace with your desired width
                    height: 100, // Replace with your desired height
                    repeat: true, // Set to true if you want the cloud animation to loop
                    frameRate: FrameRate.max,
                  ),
                  top: -600, // Adjust the top position as needed
                  left: 80, // Adjust the left position as needed
                  bottom: 0,
                ),
                Positioned(
                  child: Lottie.asset(
                    'assets/cloud.json', // Replace with the path to your cloud Lottie JSON file
                    width: 140, // Replace with your desired width
                    height: 130, // Replace with your desired height
                    repeat: true, // Set to true if you want the cloud animation to loop
                    frameRate: FrameRate.max,
                  ),
                  top: 0, // Adjust the top position as needed
                  left: 170, // Adjust the left position as needed
                  bottom: -310,
                ),
                Positioned(
                  child: Lottie.asset(
                    'assets/cloud.json', // Replace with the path to your cloud Lottie JSON file
                    width: 150, // Replace with your desired width
                    height: 150, // Replace with your desired height
                    repeat: true, // Set to true if you want the cloud animation to loop
                    frameRate: FrameRate.max,
                  ),
                  top: -80, // Adjust the top position as needed
                  left: 270, // Adjust the left position as needed
                  bottom: 250,
                ),
                Positioned(
                  child: Lottie.asset(
                    'assets/cloud.json', // Replace with the path to your cloud Lottie JSON file
                    width: 90, // Replace with your desired width
                    height: 90, // Replace with your desired height
                    repeat: true, // Set to true if you want the cloud animation to loop
                    frameRate: FrameRate.max,
                  ),
                  top: -80, // Adjust the top position as needed
                  left: 0, // Adjust the left position as needed
                  bottom: 200,
                ),
                // Cloud (larger)
                Positioned(
                  child: Lottie.asset(
                    'assets/bigcloud.json', // Replace with the path to your cloud Lottie JSON file
                    width: 550, // Replace with your desired width
                    height: 600, // Replace with your desired height
                    repeat: true, // Set to true if you want the cloud animation to loop
                    frameRate: FrameRate.max,
                  ),
                  top: 150, // Adjust the top position as needed
                  left: -70, // Adjust the left position as needed
                ),
                //running robot
                Positioned(
                  child: Lottie.asset(
                    'assets/run.json', // Replace with the path to your Lottie JSON file
                    width: 200, // Replace with your desired width
                    height: 200, // Replace with your desired height
                    repeat: true, // Set to true if you want the animation to loop
                  ),
                  top: 310, // Adjust the top position as needed (centered within the cloud)
                  left: 110, // Adjust the left position as needed (centered within the cloud)
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
