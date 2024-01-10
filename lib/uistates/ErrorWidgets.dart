import 'package:flutter/material.dart';

class ErrorOccuredWidget extends StatelessWidget {

  final String img;
  final String title;
  final List<String> message;

  ErrorOccuredWidget({required this.img,required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Upper Section with Diagonal Line
          ClipPath(
            clipper: DiagonalClipper(),
            child: Container(
              height: MediaQuery.of(context).size.height / 2.2, // Adjust the height as needed
              decoration: BoxDecoration(
                color: Color(0xFFD54D57), // Set a solid red color
              ),
              child: Center(
                child: Image.asset(
                  img, // Adjust the image path accordingly
                  height: 300.0,
                  width: 300.0,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Lower Section with Texts
          Padding(
            padding: const EdgeInsets.only(top:120.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 2 * MediaQuery.of(context).size.height / 2,
                padding: EdgeInsets.all(16.0),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 35.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      message[0],
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 25.0,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                     message[1],
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 25.0,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height - 50.0);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
