import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:marquee/marquee.dart';

class CustomDropdownMenu extends StatefulWidget {
  final List<String>? items; // Updated to allow null
  final String? value;
  final ValueChanged<String?> onChanged;
  final double menuWidth;
  final double menuHeight;
  final Color menuColor;
  final Color buttonColor;
  final Color textColor;
  final Color defaultTextColor;
  final double textFont;
  final int buttonElevated;
  final bool useMarquee; // New boolean property

  const CustomDropdownMenu({
    Key? key,
    this.items, // Updated to allow null
    required this.value,
    required this.onChanged,
    required this.menuWidth,
    required this.menuHeight,
    required this.buttonColor,
    required this.menuColor,
    required this.textColor,
    required this.defaultTextColor,
    required this.textFont,
    required this.buttonElevated,
    this.useMarquee = false,
  }) : super(key: key);

  @override
  _CustomDropdownMenuState createState() => _CustomDropdownMenuState();
}

class _CustomDropdownMenuState extends State<CustomDropdownMenu> {
  @override
  Widget build(BuildContext context) {
    if (widget.items == null || widget.items!.isEmpty) {
      // Handle case where items list is null or empty
      return Text(
        'All Booked',
        style: TextStyle(
          fontSize: widget.textFont,
          fontFamily: 'Amiri',
          fontWeight: FontWeight.bold,
          color: Color(0xFFD54D57),
        ),
        textAlign: TextAlign.center,
      );
    }

    return DropdownButton2<String>(
      isExpanded: true,
      items: widget.items!
          .map((String item) => DropdownMenuItem<String>(
        value: item,
        child: Center(
          child: widget.value == item
              ? (widget.useMarquee
              ? Marquee(
            text: item,
            style: TextStyle(
              fontSize: widget.textFont,
              fontFamily: 'Amiri',
              fontWeight: FontWeight.bold,
              color: widget.textColor,
            ),
            scrollAxis: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.center,
            blankSpace: 20.0,
            velocity: 50.0,
            pauseAfterRound: Duration(seconds: 1),
            showFadingOnlyWhenScrolling: false,
            fadingEdgeStartFraction: 0.1,
            fadingEdgeEndFraction: 0.1,
            startPadding: 10.0,
            accelerationDuration: Duration(seconds: 1),
            accelerationCurve: Curves.linear,
            decelerationDuration: Duration(milliseconds: 500),
            decelerationCurve: Curves.easeOut,
          )
              : Text(
            item,
            style: TextStyle(
              fontSize: widget.textFont,
              fontFamily: 'Amiri',
              fontWeight: FontWeight.bold,
              color: widget.textColor,
            ),
            textAlign: TextAlign.center,
          ))
              : Text(
            item,
            style: TextStyle(
              fontSize: widget.textFont,
              fontFamily: 'Amiri',
              fontWeight: FontWeight.bold,
              color: widget.textColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ))
          .toList(),
      value: widget.value,
      onChanged: (String? value) {
        setState(() {
          widget.onChanged(value);
        });
      },
      buttonStyleData: ButtonStyleData(
        height: widget.menuHeight,
        width: widget.menuWidth,
        padding: const EdgeInsets.only(left: 3.0, right: 3.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: widget.buttonColor,
        ),
        elevation: widget.buttonElevated,
      ),
      iconStyleData: IconStyleData(
        icon: Icon(
          Icons.keyboard_arrow_down_outlined,
        ),
        iconSize: 14,
        iconEnabledColor: Colors.white,
        iconDisabledColor: Colors.white,
      ),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 200,
        width: widget.menuWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: widget.menuColor,
        ),
        offset: const Offset(0, 0),
        scrollbarTheme: ScrollbarThemeData(
          radius: const Radius.circular(20),
          thickness: MaterialStateProperty.all<double>(4),
          thumbVisibility: MaterialStateProperty.all<bool>(true),
        ),
      ),
      menuItemStyleData: const MenuItemStyleData(
        height: 30,
        padding: EdgeInsets.only(left: 10, right: 10),
      ),
    );
  }
}
