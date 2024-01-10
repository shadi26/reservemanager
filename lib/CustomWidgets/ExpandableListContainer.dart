import 'package:flutter/material.dart';
import '../flutter_flow/flutter_flow_util.dart';
import 'MyExpandableCardsCon.dart';
import '../Notifiers/SelectedLanguage.dart';
import 'package:provider/provider.dart';
import 'ReusableMethods.dart';

int counter=0;
class ExpandableListContainer extends StatefulWidget   {

  final String title;
  final List<Map<String, dynamic>> cardDataList;
  final Key key;


  ExpandableListContainer({
    required this.title,
    required this.cardDataList,
    required this.key,
  });

  @override
  ExpandableListContainerState createState() =>
      ExpandableListContainerState();
}

class ExpandableListContainerState extends State<ExpandableListContainer>  with AutomaticKeepAliveClientMixin {
  bool isExpanded = false;
  // Function to set the expansion state
  void setExpanded(bool value) {
    setState(() {
      if(isExpanded)
      isExpanded = value;
    });
  }

  @override
  bool get wantKeepAlive => true;


  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    super.build(context); // Call super.build(context) at the beginning
    // Sort the list based on 'status' before building
    final selectedLanguage = Provider.of<SelectedLanguage>(context);
    List<Map<String, dynamic>> sortedList = sortCardDataList(widget.cardDataList);

    return Container(
      margin: EdgeInsets.all(10.0),
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
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
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(

            selectedLanguage.translate((widget.title+"service").toLowerCase()),
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 23.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.0),
          // List of cards in pairs
          for (int i = 0; i < sortedList.length; i += 2)
            if (isExpanded || i < 4)
              Row(
                children: [
                  MyExpandableCon.buildCard(
                      context, sortedList[i]),
                  SizedBox(width: 10.0),
                  if (i + 1 < sortedList.length)
                    MyExpandableCon.buildCard(
                        context, sortedList[i + 1]),
                  if (i + 1 >= sortedList.length)
                    MyExpandableCon.buildDummyCard(),
                ],
              ),
          // Icon at the bottom
          AnimatedCrossFade(

            firstChild: GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0,bottom: 8.0),
                child: Image.asset(
                  'assets/icons/expand_more_arrow.png',
                  width: 25.0,
                  height: 25.0,
                ),
              ),
            ),
            secondChild: GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0,bottom: 8.0),
                child: Image.asset(
                  'assets/icons/expand_less_arrow.png',
                  width: 25.0,
                  height: 25.0,
                ),
              ),
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: Duration(milliseconds: 100),
          ),

        ],
      ),
    );
  }

  List<Map<String, dynamic>> sortCardDataList(List<Map<String, dynamic>> list) {
    try {
      String currentDay = DateFormat('EEEE').format(DateTime.now());
      List<Map<String, dynamic>> openCards = [];
      List<Map<String, dynamic>> closedCards = [];

      for (var card in list) {
        // Get the opening schedule for each card
        List<dynamic> openingSchedule = card['weeklyStadiumOpeningSchedule'][currentDay] ?? [];

        // Determine the status using the provided function
        String cardStatus = ReusableMethods.determineCardStatus(openingSchedule);

        if (cardStatus == 'closed') {
          closedCards.add(card);
        } else {
          openCards.add(card);
        }
      }

      // Concatenate the open and closed cards to get the desired order
      List<Map<String, dynamic>> sortedList = openCards + closedCards;

      return sortedList;
    } catch (e) {
      print('Error sorting card data: $e');
      return list; // Return the unsorted list in case of an error
    }
  }



}



