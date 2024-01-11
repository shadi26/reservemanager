
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../pages/DateReservation/DateReservation.dart';
import '../Notifiers/SelectedLanguage.dart';
import '../Notifiers/SelectedServiceIdProvider.dart';
import '../flutter_flow/flutter_flow_util.dart';
import 'package:flutter/services.dart';
import 'ReusableMethods.dart';
int counter1=0;

class MyExpandableCon {
  static Widget buildCard(BuildContext context, Map<String, dynamic> cardData) {
    // Get the selected language from the provider
    final selectedLanguage = Provider.of<SelectedLanguage>(context);
    // Determine the card status based on the current time and opening times
    bool isDataLoaded = false;
    String currentDay = DateFormat('EEEE').format(DateTime.now());
    String cardStatus = ReusableMethods.determineCardStatus(cardData['weeklyStadiumOpeningSchedule'][currentDay] ?? []);

    return Expanded(
      child: InkWell(
        onTap: () async {
          // Assuming you have the provider instantiated in your widget tree
          SelectedServiceIdProvider selectedServiceIdProvider = Provider.of<
              SelectedServiceIdProvider>(context, listen: false);

          // Set the serviceId
          selectedServiceIdProvider.setSelectedServiceId(
              cardData['serviceId'] as String);

          // Navigate to the next screen
          pushNewScreenWithRouteSettings(
            context,
            settings: RouteSettings(
              name: 'DateReservation',
            ),
            // making new Widget but with the imageurls for this specific stadium
            screen: ReservationPage1Widget(),
            withNavBar: true,
          );
        },
        child: Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          color: Colors.white,
          elevation: 8.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(
              color: cardStatus == 'closed'
                  ? Color(0xFFBE0133).withOpacity(0.3)
                  : Color(0xFF98CA05).withOpacity(0.9),
              width: 2.0,
            ),
          ),
          child: Container(
            height: 200.0, // Set a fixed height for the card
            decoration: BoxDecoration(
              color: Colors.white, // Set the background color to white
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                CachedNetworkImage( // Use
                  height: 105,
                  width:  150,// CachedNetworkImage here
                  placeholder: (context, url) => Image.asset('assets/icons/ReserveLogo.png'), // Placeholder from assets
                  imageUrl: cardData['image'],
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
                Divider(
                  height: 2.0,
                  color: Colors.grey,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 7.0),
                  child: Text(
                    selectedLanguage.translate(cardData['title'].toLowerCase()),
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
                  child: Container(
                    width: 80.0,
                    height: 35.0,
                    decoration: BoxDecoration(
                      color: cardStatus == 'closed'
                          ? Color(0xFFBE0133)
                          : Color(0xFF98CA05),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5.0, left: 5.0),
                        child: Text(
                          selectedLanguage
                              .translate((cardStatus).toLowerCase()),
                          style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildDummyCard() {
    return Expanded(
      child: Card(
        color: Colors.transparent,
      ),
    );
  }
}

class ImageWidget extends StatelessWidget {
  final Image imageUrl;

  const ImageWidget({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
          return ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
            ),
            child: Container(
              height: 99.0,
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.cover,
                child: imageUrl,
              ),
            ),
          );
        }
  }

