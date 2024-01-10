import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Notifiers/SelectedLanguage.dart';

class CircularImageSlider extends StatelessWidget {
  final List<String> serviceNames;
  final List<String> imageAssetPaths;
  final Function(String) onServiceTapped;

  CircularImageSlider({
    required this.serviceNames,
    required this.imageAssetPaths,
    required this.onServiceTapped,
  });


  @override
  Widget build(BuildContext context) {
    final selectedLanguage = Provider.of<SelectedLanguage>(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
      child: Container(
        height: 125.0, // Adjust the height as needed
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.grey.withOpacity(0.6),
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(25.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 5), // Adjust the offset if needed
            ),

          ],
        ),
        child: ListView.builder(

          scrollDirection: Axis.horizontal,
          itemCount: serviceNames.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                onServiceTapped(serviceNames[index]);
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Container(
                      width: 85.0,
                      height: 70.0,
                      margin: EdgeInsets.symmetric(horizontal: 20.5),
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage(imageAssetPaths[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Color(0xFFD54D57).withOpacity(0.9),
                                width: 3.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 9.0), // Adjust the spacing between the image and text
                  Padding(
                    padding: const EdgeInsets.only(left: 14.5,right: 14.5),
                    child: Text(

                      selectedLanguage.translate((serviceNames[index]).replaceAll(' ', '').toLowerCase()+'service'),
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        color: Colors.black54,
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
